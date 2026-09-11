/**
 * @description Unit tests for LeadReplyHandler inbound email handler.
 * Verifies handler can be instantiated and processes basic email/envelope inputs
 * without throwing exceptions and returns a non-null Messaging.InboundEmailResult.
 */
@IsTest
private class LeadReplyHandlerTest {
    /**
     * @description Creates a minimal Messaging.InboundEmail populated with common fields
     */
    private static Messaging.InboundEmail buildEmail(String subject, String plainText, String html) {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = subject;
        email.fromAddress = 'user@example.com';
        // email.toAddress = 'sales@example.com';
        email.plainTextBody = plainText;
        email.htmlBody = html;
        return email;
    }

    /**
     * @description Creates a minimal Messaging.InboundEnvelope with from/to
     */
    private static Messaging.InboundEnvelope buildEnvelope(String fromAddr, String toAddr) {
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = fromAddr;
        env.toAddress = toAddr;
        return env;
    }

    /**
     * @description Basic happy-path test with subject, plain text and html bodies.
     */
    @IsTest
    static void testHandleInboundEmail_basic() {
        // Arrange
        LeadReplyHandler handler = new LeadReplyHandler();
        Messaging.InboundEmail email = buildEmail('Lead reply subject', 'Hello from plain text body', '<p>Hello from html</p>');
        Messaging.InboundEnvelope env = buildEnvelope('lead.sender@example.com', 'lead.reply@inbound.example.com');

        // Act
        Test.startTest();
        Messaging.InboundEmailResult res = handler.handleInboundEmail(email, env);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, res, 'Handler should return a non-null result');
        // By default, Messaging.InboundEmailResult.bSuccess is true unless explicitly set otherwise
        System.assertEquals(true, res.success, 'InboundEmailResult.success should be true by default');
    }

    /**
     * @description Test null email still handled gracefully.
     */
    @IsTest
    static void testHandleInboundEmail_nullEmail() {
        // Arrange
        LeadReplyHandler handler = new LeadReplyHandler();
        Messaging.InboundEmail email = null;
        Messaging.InboundEnvelope env = buildEnvelope('noone@example.com', 'inbound@example.com');

        // Act
        Test.startTest();
        Messaging.InboundEmailResult res = handler.handleInboundEmail(email, env);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, res, 'Handler should return a result even when email is null');
        System.assertEquals(true, res.success, 'Result should indicate success by default');
    }

    /**
     * @description Test null envelope still handled gracefully.
     */
    @IsTest
    static void testHandleInboundEmail_nullEnvelope() {
        // Arrange
        LeadReplyHandler handler = new LeadReplyHandler();
        Messaging.InboundEmail email = buildEmail('Subject only', 'Body', null);
        Messaging.InboundEnvelope env = null;

        // Act
        Test.startTest();
        Messaging.InboundEmailResult res = handler.handleInboundEmail(email, env);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, res, 'Handler should return a result even when envelope is null');
        System.assertEquals(true, res.success, 'Result should indicate success by default');
    }

    /**
     * @description Test empty bodies and attachments count path.
     */
    @IsTest
    static void testHandleInboundEmail_emptyBodies() {
        // Arrange
        LeadReplyHandler handler = new LeadReplyHandler();
        Messaging.InboundEmail email = buildEmail('Empty bodies', null, null);
        Messaging.InboundEnvelope env = buildEnvelope('from@example.com', 'to@example.com');

        // Act
        Test.startTest();
        Messaging.InboundEmailResult res = handler.handleInboundEmail(email, env);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, res, 'Result should not be null for empty bodies');
        System.assertEquals(true, res.success, 'Result should indicate success by default');
    }
}