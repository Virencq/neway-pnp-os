/*
 * Copyright (C) 2011 Jason von Nieda <jason@vonnieda.org>
 * 
 * This file is part of OpenPnP.
 * 
 * OpenPnP is free software: you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * OpenPnP is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
 * even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with OpenPnP. If not,
 * see <http://www.gnu.org/licenses/>.
 * 
 * For more information about OpenPnP visit http://openpnp.org
 */

package org.openpnp.machine.neoden4;

import java.awt.Toolkit;

import javax.swing.SwingUtilities;

import org.openpnp.gui.support.MessageBoxes;
import org.openpnp.spi.base.AbstractJobProcessor;
import org.openpnp.spi.base.AbstractSignaler;
import org.simpleframework.xml.Attribute;

/**
 * Signals job error / completion states with a dialog and a system beep. Restored so
 * configurations referencing org.openpnp.machine.neoden4.Neoden4Signaler continue to load. The
 * original hardware buzzer (via NeoDen4Driver) is not available in this build, so the sound is
 * played with the system beep instead. The configuration wizard is intentionally omitted.
 */
public class Neoden4Signaler extends AbstractSignaler implements Runnable {

    @Attribute(required = false)
    protected boolean enableErrorSound;

    @Attribute(required = false)
    protected boolean enableFinishedSound;

    private boolean playError = false;
    private boolean playSuccess = false;
    private boolean lastPlayError = false;
    private boolean lastPlaySuccess = false;

    public Neoden4Signaler() {
        Thread thread = new Thread(this);
        thread.setDaemon(true);
        thread.start();
    }

    @Override
    public void run() {
        while (!Thread.interrupted()) {
            try {
                if (playError) {
                    if (lastPlayError != playError) {
                        lastPlayError = playError;
                        if (enableErrorSound) {
                            Toolkit.getDefaultToolkit().beep();
                        }
                        SwingUtilities.invokeLater(new Runnable() {
                            @Override
                            public void run() {
                                MessageBoxes.infoBox("Job Error",
                                        "The job reported an error. Click OK to confirm.");
                                playError = false;
                                lastPlayError = false;
                            }
                        });
                    }
                    Thread.sleep(200);
                }
                else if (playSuccess) {
                    if (lastPlaySuccess != playSuccess) {
                        lastPlaySuccess = playSuccess;
                        if (enableFinishedSound) {
                            Toolkit.getDefaultToolkit().beep();
                        }
                        SwingUtilities.invokeLater(new Runnable() {
                            @Override
                            public void run() {
                                MessageBoxes.infoBox("Job Finished",
                                        "The job finished successfully. Click OK to confirm.");
                                playSuccess = false;
                                lastPlaySuccess = false;
                            }
                        });
                    }
                    Thread.sleep(200);
                }
                else {
                    Thread.sleep(200);
                }
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    public void signalJobProcessorState(AbstractJobProcessor.State state) {
        switch (state) {
            case ERROR: {
                playError = true;
                break;
            }

            case FINISHED: {
                playSuccess = true;
                break;
            }

            default: {
                break;
            }
        }
    }

    public boolean isEnableErrorSound() {
        return enableErrorSound;
    }

    public void setEnableErrorSound(boolean enableErrorSound) {
        this.enableErrorSound = enableErrorSound;
    }

    public boolean isEnableFinishedSound() {
        return enableFinishedSound;
    }

    public void setEnableFinishedSound(boolean enableFinishedSound) {
        this.enableFinishedSound = enableFinishedSound;
    }
}
