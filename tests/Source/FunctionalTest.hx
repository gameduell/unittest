/*
 * Copyright (c) 2003-2015, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import asyncrunner.Async;

class FunctionalTest extends unittest.TestCase
{
    private var counter: Int;
    private var flag: Bool;

    public function new()
    {
        super();

        counter = 0;
        flag = true;
    }

    @try(4)
    public function testRandom()
    {
        assertTrue(Math.random() > 0.3);
    }

    @try(5)
    public function testFourFailsOneSuccess()
    {
        counter++;

        assertEquals(5, counter);
    }

    @try(2)
    public function testAsyncFailsFirstTimeWorksSecond()
    {
        Async.delay(function(): Void
        {
            flag = !flag;

            // will work the 2nd time
            assertTrue(flag);

            assertAsyncFinish("testAsyncFailsFirstTimeWorksSecond");
        }, 2.0);

        assertAsyncStart("testAsyncFailsFirstTimeWorksSecond", 3.0);
    }

    @try(0)
    public function testWithZeroTries()
    {
        // should always execute once
        assertTrue(true);
    }

    @try(-1)
    public function testWithNegativeTries()
    {
        // surprise surprise, should always execute once
        assertTrue(true);
    }

    public function testWithoutTry()
    {
        assertTrue(true);
    }
}
