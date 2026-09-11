public with sharing class LeadReplyHandler implements Messaging.InboundEmailHandler {
    /**
     * @description Inbound Email Service handler for processing incoming messages.
     * @param email The inbound email content and metadata.
     * @param envelope The SMTP envelope data (from/to).
     * @return Messaging.InboundEmailResult indicating processing outcome.
     */
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        System.debug('LeadReplyHandler.handleInboundEmail invoked');
        System.debug('From: ' + (envelope != null ? envelope.fromAddress : 'null'));
        System.debug('To: ' + (envelope != null ? envelope.toAddress : 'null'));
        System.debug('Subject: ' + (email != null ? email.subject : 'null'));
        System.debug('PlainTextBody length: ' + (email != null && email.plainTextBody != null ? String.valueOf(email.plainTextBody.length()) : 'null'));
        System.debug('HtmlBody length: ' + (email != null && email.htmlBody != null ? String.valueOf(email.htmlBody.length()) : 'null'));
        System.debug('Number of attachments: ' + (email != null && email.binaryAttachments != null ? String.valueOf(email.binaryAttachments.size()) : '0'));

        // Initialize the result; default behavior accepts/does not bounce the email.
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        System.debug('Result initialized: ' + result);

        // TODO: Implement processing as needed. Use Database methods in USER_MODE for DML and add proper error handling.
        System.debug('LeadReplyHandler.handleInboundEmail completed');
        return result;
    }
}


/*
global with sharing class LeadReplyHandler implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(
        Messaging.InboundEmail email, 
        Messaging.InboundEnvelope envelope) {

        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        System.debug('🔥 Email Received!');
        System.debug('From Address: ' + email.fromAddress);
        System.debug('Subject: ' + email.subject);
        System.debug('Body: ' + email.plainTextBody);

        result.success = true;
        return result;
    }
}
*/