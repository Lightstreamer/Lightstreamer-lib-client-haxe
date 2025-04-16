/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package ls.haxe.util;

import java.util.LinkedList;
import java.util.Objects;
import java.util.concurrent.TimeoutException;

import com.lightstreamer.log.LogManager;
import com.lightstreamer.log.Logger;

/**
 * A synchronization object used to block a thread (see {@link #await(Object)}) until the expected event happens (see {@link #signal(Object)}).
 */
public class SequencingMonitor {

    static final Logger log = LogManager.getLogger("junit");

    /**
     * Stores the messages sent by {@link #signal(Object)} which are not yet processed by {@link #await(Object)}.
     */
    private final MyQueue eventQueue = new MyQueue();

    /**
     * Blocks the calling thread until someone calls {@link #signal(Object)} with an argument equal to {@code expected}.
     */
    public synchronized void await(Object expected) throws InterruptedException {
        while (true) {
            if (eventQueue.isEmpty()) {
                wait();

            } else {
                Object msg = eventQueue.pop();
                if ((msg == null && expected == null) || (msg != null && msg.equals(expected))) {
                    break;
                }
            }
        }
    }

    /**
     * Blocks the calling thread until the message "CONNECTED:WS-*" or "CONNECTED:HTTP-*" is received.
     */
    public synchronized void awaitConnected() throws InterruptedException {
        while (true) {
            if (eventQueue.isEmpty()) {
                wait();

            } else {
                Object msg = eventQueue.pop();
                if (msg instanceof String) {
                    String str = (String) msg;
                    if (str.startsWith("CONNECTED:WS-") || str.startsWith("CONNECTED:HTTP-")) {
                        break;
                    }
                }
            }
        }
    }

    /**
     * Blocks the calling thread until someone calls {@link #signal(Object)} twice in a row
     * with arguments equal to {@code expected1} and to {@code expected2} whatever the order.
     * If a different object is received, the method throws {@link AssertionError}.
     */
    public synchronized void awaitUnordered(Object expected1, Object expected2) throws InterruptedException {
        boolean found1 = false;
        boolean found2 = false;
        while (!(found1 && found2)) {
            if (eventQueue.isEmpty()) {
                wait();

            } else {
                Object msg = eventQueue.pop();
                if (!found1  && Objects.equals(msg, expected1)) {
                    found1 = true;
                } else if (!found2 && Objects.equals(msg, expected2)) {
                    found2 = true;
                } else {
                    assert !(found1 && found2);
                    throw new AssertionError("Unexpected message: " + msg);
                }
            }
        }
    }

    /**
     * Blocks the calling thread until someone calls {@link #signal(Object)} with an argument starting with {@code prefix}.
     */
    public synchronized String awaitMessageStartingWith(String prefix) throws InterruptedException {
        while (true) {
            if (eventQueue.isEmpty()) {
                wait();

            } else {
                Object msg = eventQueue.pop();
                if (msg instanceof String && ((String) msg).startsWith(prefix)) {
                    return (String) msg;
                }
            }
        }
    }

    /**
     * Same as {@link #awaitMessageStartingWith(String)}.
     */
    public synchronized String awaitPrefix(String prefix) throws InterruptedException {
        return awaitMessageStartingWith(prefix);
    }

    /**
     * Blocks the calling thread until someone calls {@link #signal(Object)} with a string argument starting with {@code prefix}
     * or the timeout expires. In the last case this method throws {@link TimeoutException}.
     */
    public synchronized void awaitMessageStartingWith(String prefix, long timeout) throws InterruptedException, TimeoutException {
        long end = System.currentTimeMillis() + timeout;
        while (true) {
            long delay = end - System.currentTimeMillis();
            if (delay <= 0) {
                throw new TimeoutException();
            }
            if (eventQueue.isEmpty()) {
                assert delay != 0;
                wait(delay);

            } else {
                Object msg = eventQueue.pop();
                if (msg instanceof String && ((String) msg).startsWith(prefix)) {
                    break;
                }
            }
        }
    }

    public interface Condition {
        boolean test();
    }

    /**
     * Blocks the current thread until the condition is true.
     */
    public synchronized void awaitUntil(Condition cond) throws InterruptedException {
        while (! cond.test()) {
            wait(50);
        }
    }

    /**
     * Blocks the calling thread until someone calls {@link #signal(Object)} with an instance of the given class.
     */
    public synchronized <T> T await(Class<T> expectedType) throws InterruptedException {
        while (true) {
            if (eventQueue.isEmpty()) {
                wait();

            } else {
                Object msg = eventQueue.pop();
                if (expectedType.isInstance(msg)) {
                    return (T) msg;
                }
            }
        }
    }

    /**
     * Blocks the calling thread until an event occurs.
     * Throws {@link AssertionError} (and removes the event from the queue) if the event equals the argument.
     * If the event is not equal to the argument, the event is not removed from the queue.
     */
    public synchronized void reject(String notExpected) throws InterruptedException {
        while (eventQueue.isEmpty()) {
            wait();
        }
        Object msg = eventQueue.peek();
        if (Objects.equals(msg, notExpected)) {
            eventQueue.pop();
            throw new AssertionError("Unexpected message: " + notExpected);
        }
    }

    /**
     * Blocks the calling thread until the timeout expires or someone calls {@link #signal(Object)} with a string argument
     * starting with {@code prefix}. In the last case this method throws {@link AssertionError}.
     */
    public synchronized void rejectMessageStartingWith(String prefix, long timeout) throws InterruptedException {
        long end = System.currentTimeMillis() + timeout;
        while (true) {
            long delay = end - System.currentTimeMillis();
            if (delay <= 0) {
                return; // timeout elapsed and no sign of the message
            }
            if (eventQueue.isEmpty()) {
                assert delay != 0;
                wait(delay);

            } else {
                Object msg = eventQueue.pop();
                if (msg instanceof String && ((String) msg).startsWith(prefix)) {
                    throw new AssertionError("Unexpected message: " + prefix);
                }
            }
        }
    }

    /**
     * Signals to threads blocked on {@link #await(Object)} that a new message has arrived.
     */
    public synchronized void signal(Object msg) {
        log.debug("Signal: " + msg, null);
        assert eventQueue.size() < 128; // if the queue grows too much, probably the calling test is broken
        eventQueue.add(msg);
        notifyAll();
    }

    /**
     * Signals to threads blocked on {@link #await(Object)} that two new messages have arrived.
     */
    public synchronized void signal(Object m1, Object m2) {
        log.debug("Signal: " + m1, null);
        log.debug("Signal: " + m2, null);
        assert eventQueue.size() < 128; // if the queue grows too much, probably the calling test is broken
        eventQueue.add(m1);
        eventQueue.add(m2);
        notifyAll();
    }

    /**
     * Returns an {@link Observer} observing the incoming messages.
     * <p>
     * This method is useful when we don't know the order of a message with respect of other messages.
     * Suppose for example that message X can be after message M1 or M2 or M3, then we can code this expectation
     * in the following way:
     *
     * <pre>
     * SequencingMonitor m = new SequencingMonitor();
     * Observer o = m.peekAt("X");
     * m.await("M1");
     * // X can be here
     * m.await("M2");
     * // or here
     * m.await("M3");
     * // or here
     * o.awaitUntilFound();
     * </pre>
     */
    public synchronized Observer peekAt(Object expected) throws InterruptedException {
        Observer o = new Observer(expected);
        eventQueue.addObserver(o);
        return o;
    }

    /**
     * Observes the messages sent by {@link SequencingMonitor#signal(Object)}
     * searching the expected message specified by {@link SequencingMonitor#peekAt(Object)}.
     */
    public class Observer {
        private final Object expected;
        private boolean found = false;

        Observer(Object expected) {
            this.expected = expected;
        }

        synchronized void check(Object msg) {
            if (expected.equals(msg)) {
                found = true;
            }
        }

        /**
         * Throws an {@link AssertionError} if the expected message was not found.
         */
        public synchronized void found() {
            eventQueue.removeObserver(this);
            if (! found) {
                throw new AssertionError(expected + " not found");
            }
        }

        /**
         * Blocks the calling thread until the expected message is found.
         */
        public synchronized void awaitUntilFound() throws InterruptedException {
            eventQueue.removeObserver(this);
            if (! found) {
                await(expected);
            }
        }
    }

    /**
     * A queue notifying the attached observers when an element is popped.
     */
    private static class MyQueue {
        final LinkedList<Object> eventQueue = new LinkedList<>();
        final LinkedList<Observer> observers = new LinkedList<>();

        void addObserver(Observer o) {
            observers.add(o);
        }

        void removeObserver(Observer o) {
            observers.remove(o);
        }

        Object pop() {
            Object o = eventQueue.pop();
            for (Observer observer : observers) {
                observer.check(o);
            }
            return o;
        }

        boolean isEmpty() {
            return eventQueue.isEmpty();
        }

        Object peek() {
            return eventQueue.peek();
        }

        boolean add(Object msg) {
            return eventQueue.add(msg);

        }

        int size() {
            return eventQueue.size();
        }
    }
}
