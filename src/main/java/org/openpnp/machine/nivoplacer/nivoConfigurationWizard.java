/*
 * Copyright (C) 2011 Jason von Nieda <jason@vonnieda.org>
 *
 * This file is part of OpenPnP.
 *
 * OpenPnP is free software: you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * OpenPnP is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
 * Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with OpenPnP. If not, see
 * <http://www.gnu.org/licenses/>.
 *
 * For more information about OpenPnP visit http://openpnp.org
 */

package org.openpnp.machine.nivoplacer;

import com.google.zxing.BinaryBitmap;
import com.google.zxing.Result;
import com.google.zxing.ResultPoint;
import com.google.zxing.client.j2se.BufferedImageLuminanceSource;
import com.google.zxing.common.HybridBinarizer;
import com.google.zxing.multi.MultipleBarcodeReader;
import com.google.zxing.multi.qrcode.QRCodeMultiReader;
import com.jgoodies.forms.layout.ColumnSpec;
import com.jgoodies.forms.layout.FormLayout;
import com.jgoodies.forms.layout.FormSpecs;
import com.jgoodies.forms.layout.RowSpec;
import org.jdesktop.beansbinding.AutoBinding.UpdateStrategy;
import org.openpnp.gui.components.ComponentDecorators;
import org.openpnp.gui.components.LocationButtonsPanel;
import org.openpnp.gui.support.IntegerConverter;
import org.openpnp.gui.support.LengthConverter;
import org.openpnp.gui.support.MutableLocationProxy;
import org.openpnp.machine.reference.feeder.wizards.AbstractReferenceFeederConfigurationWizard;
import org.openpnp.model.Configuration;
import org.openpnp.model.Location;
import org.openpnp.spi.Camera;
import org.openpnp.spi.Feeder;
import org.openpnp.spi.Machine;
import org.openpnp.util.MovableUtils;
import org.openpnp.util.UiUtils;
import org.openpnp.util.Utils2D;
import org.openpnp.util.VisionUtils;

import javax.swing.*;
import javax.swing.border.TitledBorder;
import java.awt.event.ActionEvent;
import java.awt.image.BufferedImage;
import java.util.HashSet;
import java.util.Set;

public class nivoConfigurationWizard
        extends AbstractReferenceFeederConfigurationWizard {
    private final nivo feeder;
    private final Action scanAction = new AbstractAction("Scan") {
        @Override
        public void actionPerformed(ActionEvent e) {
            UiUtils.submitUiMachineTask(() -> {
                /**
                 * We'll collect all the QR codes we find in this set.
                 */
                Set<QrCodeLocation> qrCodes = new HashSet<QrCodeLocation>();

                Machine machine = Configuration.get().getMachine();
                Camera camera = machine.getDefaultHead().getDefaultCamera();

                /**
                 * Starting at the startLocation, scanning at intervals of the scanIncrement,
                 * find any barcodes visible in the frame.
                 */
                int last = (int) (feeder.getScanStartLocation()
                        .getLinearLengthTo(feeder.getScanEndLocation())
                        .divide(feeder.getScanIncrement())
                        + 1e-5); // Round up marginally for binary vs. decimal robustness to include the end point.
                for (int scan = 0; scan <= last; scan++) {
                    Location l = Utils2D.getPointAlongLine(feeder.getScanStartLocation(), feeder.getScanEndLocation(),
                            feeder.getScanIncrement().multiply(scan));
                    MovableUtils.moveToLocationAtSafeZ(camera, l);
                    try {
                        Set<QrCodeLocation> results = locateQrCodes(camera);
                        qrCodes.addAll(results);
                    } catch (Exception e1) {
                        /**
                         * We expect there to be frames with no feeders because there may
                         * be gaps in the installed feeders, so don't sweat it.
                         */
                    }
                }

                for (QrCodeLocation qr : qrCodes) {
                    /**
                     * Find or create a feeder with the name equal to the QR code.
                     */
                    nivo found = null;
                    for (Feeder f : machine.getFeeders()) {
                        if (f instanceof nivo && f.getName().equals(qr.text)) {
                            found = (nivo) f;
                            break;
                        }
                    }
                    if (found == null) {
                        found = new nivo();
                        found.setName(qr.text);
                        machine.addFeeder(found);
                    }

                    /**
                     * Update the feeder's address and pick location with the QR code data.
                     */
                    found.setLocation(qr.location);
                    found.setAddress(qr.text);
                    if (found.getPart() == null) {
                        found.setPart(Configuration.get().getParts().get(0));
                    }
                }
            });
        }
    };
    private JLabel lblNewLabel;
    private JLabel lblNewLabel_1;
    private JLabel lblNewLabel_2;
    private JTextField startX;
    private JTextField startY;
    private LocationButtonsPanel scanStart;
    private JTextField endX;
    private JTextField endY;
    private JTextField inc;
    private LocationButtonsPanel scanEnd;
    private JLabel lblNewLabel_3;
    private JLabel lblNewLabel_4;
    private JPanel panelNivoConfig;
    private JLabel lblNewLabel_5;
    private JLabel lblNewLabel_6;
    private JTextField address;
    private JTextField pitch;
    public nivoConfigurationWizard(nivo feeder) {
        super(feeder);
        this.feeder = feeder;
        createUi();
    }

    private void createUi() {

        panelNivoConfig = new JPanel();
        panelNivoConfig.setBorder(new TitledBorder(null, "NIVO Feeder Config", TitledBorder.LEADING, TitledBorder.TOP, null, null));
        contentPanel.add(panelNivoConfig);
        panelNivoConfig.setLayout(new FormLayout(new ColumnSpec[]{
                FormSpecs.RELATED_GAP_COLSPEC,
                FormSpecs.DEFAULT_COLSPEC,
                FormSpecs.RELATED_GAP_COLSPEC,
                FormSpecs.DEFAULT_COLSPEC,},
                new RowSpec[]{
                        FormSpecs.RELATED_GAP_ROWSPEC,
                        FormSpecs.DEFAULT_ROWSPEC,
                        FormSpecs.RELATED_GAP_ROWSPEC,
                        FormSpecs.DEFAULT_ROWSPEC,}));

        lblNewLabel_5 = new JLabel("Address");
        panelNivoConfig.add(lblNewLabel_5, "2, 2, right, default");

        address = new JTextField();
        panelNivoConfig.add(address, "4, 2");
        address.setColumns(32);

        lblNewLabel_6 = new JLabel("Pitch");
        panelNivoConfig.add(lblNewLabel_6, "2, 4, right, default");

        pitch = new JTextField();
        panelNivoConfig.add(pitch, "4, 4, left, default");
        pitch.setColumns(10);

        JPanel panelNivoScan = new JPanel();
        panelNivoScan.setBorder(new TitledBorder(null, "NIVO Feeder Scanning", TitledBorder.LEADING, TitledBorder.TOP, null));
        contentPanel.add(panelNivoScan);
        panelNivoScan.setLayout(new FormLayout(new ColumnSpec[]{
                FormSpecs.RELATED_GAP_COLSPEC,
                FormSpecs.DEFAULT_COLSPEC,
                FormSpecs.RELATED_GAP_COLSPEC,
                ColumnSpec.decode("left:default"),
                FormSpecs.RELATED_GAP_COLSPEC,
                ColumnSpec.decode("left:default"),
                FormSpecs.RELATED_GAP_COLSPEC,
                ColumnSpec.decode("left:default"),},
                new RowSpec[]{
                        FormSpecs.RELATED_GAP_ROWSPEC,
                        FormSpecs.DEFAULT_ROWSPEC,
                        FormSpecs.RELATED_GAP_ROWSPEC,
                        FormSpecs.DEFAULT_ROWSPEC,
                        FormSpecs.RELATED_GAP_ROWSPEC,
                        FormSpecs.DEFAULT_ROWSPEC,
                        FormSpecs.RELATED_GAP_ROWSPEC,
                        FormSpecs.DEFAULT_ROWSPEC,
                        FormSpecs.RELATED_GAP_ROWSPEC,
                        FormSpecs.DEFAULT_ROWSPEC,}));

        lblNewLabel_3 = new JLabel("X");
        panelNivoScan.add(lblNewLabel_3, "4, 2, center, default");

        lblNewLabel_4 = new JLabel("Y");
        panelNivoScan.add(lblNewLabel_4, "6, 2, center, default");

        lblNewLabel = new JLabel("Scan Start Location");
        panelNivoScan.add(lblNewLabel, "2, 4, right, default");

        startX = new JTextField();
        panelNivoScan.add(startX, "4, 4");
        startX.setColumns(10);

        startY = new JTextField();
        panelNivoScan.add(startY, "6, 4");
        startY.setColumns(10);

        scanStart = new LocationButtonsPanel(startX, startY, null, null);
        panelNivoScan.add(scanStart, "8, 4");

        lblNewLabel_1 = new JLabel("Scan End Location");
        panelNivoScan.add(lblNewLabel_1, "2, 6, right, default");

        endX = new JTextField();
        endX.setColumns(10);
        panelNivoScan.add(endX, "4, 6");

        endY = new JTextField();
        endY.setColumns(10);
        panelNivoScan.add(endY, "6, 6");

        scanEnd = new LocationButtonsPanel(endX, endY, null, null);
        panelNivoScan.add(scanEnd, "8, 6, default, fill");

        lblNewLabel_2 = new JLabel("Scan Increment");
        panelNivoScan.add(lblNewLabel_2, "2, 8, right, default");

        inc = new JTextField();
        inc.setColumns(10);
        panelNivoScan.add(inc, "4, 8, 3, 1");

        JButton btnNewButton = new JButton(scanAction);
        panelNivoScan.add(btnNewButton, "2, 10");
    }

    @Override
    public void createBindings() {
        super.createBindings();

        IntegerConverter intConverter = new IntegerConverter();
        LengthConverter lengthConverter = new LengthConverter();

        MutableLocationProxy scanStartLocation = new MutableLocationProxy();
        bind(UpdateStrategy.READ_WRITE, feeder, "scanStartLocation", scanStartLocation, "location");
        addWrappedBinding(scanStartLocation, "lengthX", startX, "text", lengthConverter);
        addWrappedBinding(scanStartLocation, "lengthY", startY, "text", lengthConverter);
        ComponentDecorators.decorateWithAutoSelectAndLengthConversion(startX);
        ComponentDecorators.decorateWithAutoSelectAndLengthConversion(startY);

        MutableLocationProxy scanEndLocation = new MutableLocationProxy();
        bind(UpdateStrategy.READ_WRITE, feeder, "scanEndLocation", scanEndLocation, "location");
        addWrappedBinding(scanEndLocation, "lengthX", endX, "text", lengthConverter);
        addWrappedBinding(scanEndLocation, "lengthY", endY, "text", lengthConverter);
        ComponentDecorators.decorateWithAutoSelectAndLengthConversion(endX);
        ComponentDecorators.decorateWithAutoSelectAndLengthConversion(endY);

        addWrappedBinding(feeder, "scanIncrement", inc, "text", lengthConverter);
        ComponentDecorators.decorateWithAutoSelectAndLengthConversion(inc);

        addWrappedBinding(feeder, "address", address, "text");
        ComponentDecorators.decorateWithAutoSelect(address);

        addWrappedBinding(feeder, "pitch", pitch, "text", intConverter);
        ComponentDecorators.decorateWithAutoSelect(pitch);
    }

    private Set<QrCodeLocation> locateQrCodes(Camera camera) throws Exception {
        BufferedImage image = camera.lightSettleAndCapture();
        BinaryBitmap binaryBitmap = new BinaryBitmap(new HybridBinarizer(
                new BufferedImageLuminanceSource(image)));
        MultipleBarcodeReader reader = new QRCodeMultiReader();
        Result[] results = reader.decodeMultiple(binaryBitmap);
        Set<QrCodeLocation> qrCodes = new HashSet<>();
        for (Result result : results) {
            qrCodes.add(new QrCodeLocation(camera, result));
        }
        return qrCodes;
    }

    /**
     * Stores information about a QR code found on the machine.
     */
    class QrCodeLocation {
        public String text;
        public Location location;

        public QrCodeLocation(Camera camera, Result result) {
            text = result.getText();

            /**
             * Find the average of the result points to find the approximate center of the QR
             * code. In the future, this should instead calculate the exact center using only
             * the three primary points which form a triangle. Or, maybe the QR code spec says
             * something about the center with regard to the four points. Look into it.
             */
            double x = 0;
            double y = 0;
            for (ResultPoint point : result.getResultPoints()) {
                x += point.getX();
                y += point.getY();
            }
            x /= result.getResultPoints().length;
            y /= result.getResultPoints().length;

            location = VisionUtils.getPixelLocation(camera, x, y);
        }

        @Override
        public String toString() {
            return text + " " + location;
        }

        @Override
        public int hashCode() {
            return text.hashCode();
        }

        @Override
        public boolean equals(Object obj) {
            if (!(obj instanceof QrCodeLocation)) {
                return false;
            }
            return text.equals(((QrCodeLocation) obj).text);
        }
    }
}
