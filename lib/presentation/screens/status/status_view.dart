import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../core/models/status.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/datetime.dart';

import '../../../core/widgets/ui_elements/status_modal_bottom_sheet.dart';
import 'status_viewmodel.dart';

class StatusPage extends StatefulWidget {
  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage>
    with AutomaticKeepAliveClientMixin {
  StatusViewModel _model;
  // build personal status listile
  Widget _buildPersonalStatus() {
    var leading = _getStatusLeading();
    return ListTile(
      leading: leading,
      title: Text('My status'),
      subtitle: Text(_model.userStatus ?? 'Tap to add status update'),
      onTap: () {
        // show status modal bottom sheet
        showStatusModalBottomSheet(context);
      },
    );
  }

  // build users status widget
  Widget _buildStatus(Status status) {
    final timeAgo = formatDateTime(status.timestamp);
    final allowDelete = _model.allowDelete(status.userName);
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(status.profileUrl),
        backgroundColor: Colors.grey,
      ),
      title: Text(status.userName),
      subtitle: Text(
        status.content,
      ),
      trailing: Text(
        timeAgo,
        style: Theme.of(context).textTheme.caption,
      ),
      // only user can delete its own status
      onTap: allowDelete ? () => _model.handleDeleteStatus(status) : null,
    );
  }

  // build divider text widget
  Widget _buildDividerText() {
    return Container(
        padding: const EdgeInsets.fromLTRB(15, 6, 0, 6),
        alignment: Alignment.centerLeft,
        child: const Text('Recent updates'));
  }

  // build users status widgets from firestore collection snapthots
  Widget _buildUsersStatus() {
    return StreamBuilder<QuerySnapshot>(
      stream: _model.statusStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        if (snapshot.hasError) {
          return Text(snapshot.error);
        }

        return Expanded(
            child: Scrollbar(
          child: ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              var status = Status.fromJsonMap(snapshot.data.docs[index].data(),
                  snapshot.data.docs[index].id);
              return _buildStatus(status);
            },
          ),
        ));
      },
    );
  }

  // handle personal status leading widget
  Widget _getStatusLeading() {
    var _isLight = Theme.of(context).brightness == Brightness.light;
    return _model.downloadUrl == null
        ? CircleAvatar(
            backgroundColor:
                _isLight ? Theme.of(context).primaryColor : Colors.blue,
          )
        : CircleAvatar(
            backgroundImage: NetworkImage(_model.downloadUrl),
            backgroundColor:
                _isLight ? Theme.of(context).primaryColor : Colors.blue,
          );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ViewModelBuilder<StatusViewModel>.reactive(
      viewModelBuilder: () => StatusViewModel(),
      onModelReady: (model) => model.initalise(),
      builder: (context, model, child) {
        _model = model;
        return Scaffold(
            body: Column(
          children: [
            _buildPersonalStatus(),
            _buildDividerText(),
            _buildUsersStatus()
          ],
        ));
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
