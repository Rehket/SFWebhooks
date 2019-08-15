/** Original License
 * Copyright (c) 2013 Kevin M. O'Hara
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom
 * the Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall
 * be included in all copies or substantial portions of the
 * Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
 * KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
 * WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
 * OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

@isTest
private class TriggerHandler_Test {
    private static final String TRIGGER_CONTEXT_ERROR = 'Trigger handler called outside of Trigger execution';

    private static String lastMethodCalled;

    private static TriggerHandler_Test.TestHandler handler;

    // override its internal trigger detection
    static {
        handler = new TriggerHandler_Test.TestHandler();
        handler.isTriggerExecuting = true;
    }

    /***************************************
     * unit tests
     ***************************************/

    // contexts tests

    @isTest
    static void testBeforeInsert() {
        beforeInsertMode();
        handler.run();
        System.assertEquals(
            'beforeInsert',
            lastMethodCalled,
            'last method should be beforeInsert'
        );
    }

    @isTest
    static void testBeforeUpdate() {
        beforeUpdateMode();
        handler.run();
        System.assertEquals(
            'beforeUpdate',
            lastMethodCalled,
            'last method should be beforeUpdate'
        );
    }

    @isTest
    static void testBeforeDelete() {
        beforeDeleteMode();
        handler.run();
        System.assertEquals(
            'beforeDelete',
            lastMethodCalled,
            'last method should be beforeDelete'
        );
    }

    @isTest
    static void testAfterInsert() {
        afterInsertMode();
        handler.run();
        System.assertEquals(
            'afterInsert',
            lastMethodCalled,
            'last method should be afterInsert'
        );
    }

    @isTest
    static void testAfterUpdate() {
        afterUpdateMode();
        handler.run();
        System.assertEquals(
            'afterUpdate',
            lastMethodCalled,
            'last method should be afterUpdate'
        );
    }

    @isTest
    static void testAfterDelete() {
        afterDeleteMode();
        handler.run();
        System.assertEquals(
            'afterDelete',
            lastMethodCalled,
            'last method should be afterDelete'
        );
    }

    @isTest
    static void testAfterUndelete() {
        afterUndeleteMode();
        handler.run();
        System.assertEquals(
            'afterUndelete',
            lastMethodCalled,
            'last method should be afterUndelete'
        );
    }

    @isTest
    static void testNonTriggerContext() {
        try {
            handler.run();
            System.assert(false, 'the handler ran but should have thrown');
        } catch (TriggerHandler.TriggerHandlerException te) {
            System.assertEquals(
                TRIGGER_CONTEXT_ERROR,
                te.getMessage(),
                'the exception message should match'
            );
        } catch (Exception e) {
            System.assert(
                false,
                'the exception thrown was not expected: ' + e.getTypeName() +
                ': ' +
                e.getMessage()
            );
        }
    }

    // test bypass api

    @isTest
    static void testBypassAPI() {
        afterUpdateMode();


        // test a bypass and run handler
        TriggerHandler.bypass('TestHandler');
        handler.run();
        System.assertEquals(
            null,
            lastMethodCalled,
            'last method should be null when bypassed'
        );
        System.assertEquals(
            true,
            TriggerHandler.isBypassed('TestHandler'),
            'test handler should be bypassed'
        );
        resetTest();


        // clear that bypass and run handler
        TriggerHandler.clearBypass('TestHandler');
        handler.run();
        System.assertEquals(
            'afterUpdate',
            lastMethodCalled,
            'last method called should be afterUpdate'
        );
        System.assertEquals(
            false,
            TriggerHandler.isBypassed('TestHandler'),
            'test handler should be bypassed'
        );
        resetTest();


        // test a re-bypass and run handler
        TriggerHandler.bypass('TestHandler');
        handler.run();
        System.assertEquals(
            null,
            lastMethodCalled,
            'last method should be null when bypassed'
        );
        System.assertEquals(
            true,
            TriggerHandler.isBypassed('TestHandler'),
            'test handler should be bypassed'
        );
        resetTest();


        // clear all bypasses and run handler
        TriggerHandler.clearAllBypasses();
        handler.run();
        System.assertEquals(
            'afterUpdate',
            lastMethodCalled,
            'last method called should be afterUpdate'
        );
        System.assertEquals(
            false,
            TriggerHandler.isBypassed('TestHandler'),
            'test handler should be bypassed'
        );
        resetTest();
    }

    // private method tests

    @isTest
    static void testGetHandlerName() {
        System.assertEquals(
            'TestHandler',
            handler.getHandlerName(),
            'handler name should match class name'
        );
    }

    // test virtual methods

    @isTest
    static void testVirtualMethods() {
        TriggerHandler h = new TriggerHandler();
        h.beforeInsert();
        h.beforeUpdate();
        h.beforeDelete();
        h.afterInsert();
        h.afterUpdate();
        h.afterDelete();
        h.afterUndelete();
    }

    /***************************************
     * testing utilities
     ***************************************/

    private static void resetTest() {
        lastMethodCalled = null;
    }

    // modes for testing

    private static void beforeInsertMode() {
        handler.setTriggerContext('before insert', true);
    }

    private static void beforeUpdateMode() {
        handler.setTriggerContext('before update', true);
    }

    private static void beforeDeleteMode() {
        handler.setTriggerContext('before delete', true);
    }

    private static void afterInsertMode() {
        handler.setTriggerContext('after insert', true);
    }

    private static void afterUpdateMode() {
        handler.setTriggerContext('after update', true);
    }

    private static void afterDeleteMode() {
        handler.setTriggerContext('after delete', true);
    }

    private static void afterUndeleteMode() {
        handler.setTriggerContext('after undelete', true);
    }

    // test implementation of the TriggerHandler

    private class TestHandler extends TriggerHandler {
        public override void beforeInsert() {
            TriggerHandler_Test.lastMethodCalled = 'beforeInsert';
        }

        public override void beforeUpdate() {
            TriggerHandler_Test.lastMethodCalled = 'beforeUpdate';
        }

        public override void beforeDelete() {
            TriggerHandler_Test.lastMethodCalled = 'beforeDelete';
        }

        public override void afterInsert() {
            TriggerHandler_Test.lastMethodCalled = 'afterInsert';
        }

        public override void afterUpdate() {
            TriggerHandler_Test.lastMethodCalled = 'afterUpdate';
        }

        public override void afterDelete() {
            TriggerHandler_Test.lastMethodCalled = 'afterDelete';
        }

        public override void afterUndelete() {
            TriggerHandler_Test.lastMethodCalled = 'afterUndelete';
        }
    }
}