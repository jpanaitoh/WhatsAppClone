import 'package:WhatsAppClone/services/api/dialogflow.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class DialogFlowAPIMock extends Mock implements DialogFlowAPI {}

void main() {
  group('dialogflow api tests - ', () {
    test('when call response should return a text message', () async {
      final dialogflow = DialogFlowAPIMock();
      const query = 'hello!';
      const msg = 'Hi, how are you?';
      when(dialogflow.response(query))
          .thenAnswer((realInvocation) => Future.value(msg));
      final response = await dialogflow.response(query);
      expect(response, msg);
    });

    test(
        'when call reponse should raise exception and return null text message',
        () async {
      final dialogflow = DialogFlowAPIMock();
      const query = 'hello!';
      when(dialogflow.response(query))
          .thenAnswer((realInvocation) => Future.value());
      final response = await dialogflow.response(query);
      expect(response, null);
    });
  });
}
