package io.github.edufolly.flutterbluetoothserial;

import android.annotation.TargetApi;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.UUID;
import java.util.Arrays;
import android.content.Context;
import android.util.Log;

import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothProfile;

/// Universal Bluetooth serial connection class (for Java)
public abstract class BluetoothConnection {
    private static final String TAG = "FlutterBluePlugin";
    protected static final UUID DEFAULT_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");

    protected BluetoothAdapter bluetoothAdapter;

    protected ConnectionThread connectionThread = null;

    protected BluetoothGatt bluetoothGatt;

    private byte[] rxValue = {};
    private byte[] txValue = {};

    private Handler handler = initMessage();

    private final static UUID UUID_1800_SERV = UUID.fromString("00001800-0000-1000-8000-00805F9B34FB"),
            UUID_1800_NAME = UUID.fromString("0000180A-0000-1000-8000-00805F9B34FB"), // 15byte
            UUID_180A_SERV = UUID.fromString("0000180A-0000-1000-8000-00805F9B34FB"),
            UUID_180A_VER = UUID.fromString("00002A26-0000-1000-8000-00805F9B34FB"), // x.x.x(ASCII/read only)
            UUID_180A_MOD = UUID.fromString("00002A24-0000-1000-8000-00805F9B34FB"), // x.x.x(ASCII/read only)
            UUID_NOTIFY = UUID.fromString("00002902-0000-1000-8000-00805F9B34FB"), //

            UUID_BLE_SERV = UUID.fromString("0003ABCD-0000-1000-8000-00805F9B0131"),
            UUID_BLE5DATA = UUID.fromString("00031234-0000-1000-8000-00805f9b0130"),
            UUID_BLE5SENT = UUID.fromString("00031234-0000-1000-8000-00805f9b0131"),
            UUID_BLE5CONF = UUID.fromString("00031234-0000-1000-8000-00805f9b0132"),
            UUID_BLE5NAME = UUID.fromString("00031234-0000-1000-8000-00805f9b0134");

    private WriteQueue writeQueue = new WriteQueue();

    public boolean isConnected() {
        return connectionThread != null && connectionThread.requestedClosing != true;
    }

    public BluetoothConnection(BluetoothAdapter bluetoothAdapter) {
        this.bluetoothAdapter = bluetoothAdapter;
    }

    // @TODO . `connect` could be done perfored on the other thread
    // @TODO . `connect` parameter: timeout
    // @TODO . `connect` other methods than `createRfcommSocketToServiceRecord`,
    // including hidden one raw `createRfcommSocket` (on channel).
    // @TODO ? how about turning it into factoried?
    /// Connects to given device by hardware address
    public void connect(String address, UUID uuid) throws IOException {
        if (isConnected()) {
            throw new IOException("already connected");
        }

        BluetoothDevice device = bluetoothAdapter.getRemoteDevice(address);
        if (device == null) {
            throw new IOException("device not found");
        }

        BluetoothSocket socket = device.createRfcommSocketToServiceRecord(uuid);
        // @TODO . introduce ConnectionMethod
        if (socket == null) {
            throw new IOException("socket connection not established");
        }

        // Cancel discovery, even though we didn't start it
        bluetoothAdapter.cancelDiscovery();

        socket.connect();

        connectionThread = new ConnectionThread(socket);
        connectionThread.start();
    }

    /// Connects to given device by hardware address (default UUID used)
    public void connect(String address) throws IOException {
        connect(address, DEFAULT_UUID);
    }

    public void connectPlus(Context activeContext, String address) throws IOException {
        if (isConnected()) {
            throw new IOException("already connected");
        }

        BluetoothDevice device = bluetoothAdapter.getRemoteDevice(address);
        if (device == null) {
            throw new IOException("device not found");
        }
        if (bluetoothGatt != null) {
            bluetoothGatt.disconnect();
            bluetoothGatt.close();
            bluetoothGatt = null;
        }

        bluetoothGatt = device.connectGatt(activeContext, false, btCallback);
        if (bluetoothGatt == null) {
            return;
        }

        // Cancel discovery, even though we didn't start it
        bluetoothAdapter.cancelDiscovery();

        bluetoothGatt.connect();
    }

    /// Disconnects current session (ignore if not connected)
    public void disconnect() {
        if (isConnected()) {
            connectionThread.cancel();
            connectionThread = null;
        }
    }

    /// Writes to connected remote device
    public void write(byte[] data) throws IOException {
        if (!isConnected()) {
            throw new IOException("not connected");
        }

        connectionThread.write(data);
    }

    /// Callback for reading data.
    protected abstract void onRead(byte[] data);

    public void writePlus(final byte[] value) {
        rxValue = new byte[] {};
        writeQueue.queueRunnable(new Runnable() {
            @Override
            public void run() {
                if (bluetoothGatt == null) {
                    return;
                }
                BluetoothGattService serv = bluetoothGatt.getService(UUID_BLE_SERV);
                if (serv == null) {
                    writeQueue.issue();
                    return;
                }

                BluetoothGattCharacteristic chara = serv.getCharacteristic(UUID_BLE5SENT);

                if (chara == null) {
                    writeQueue.issue();
                    return;
                }
                chara.setValue(value);
                bluetoothGatt.writeCharacteristic(chara);
            }
        });
    }

    private void read(final UUID uuid_serv, final UUID uuid_conf) {
        writeQueue.queueRunnable(new Runnable() {
            @Override
            public void run() {
                if (bluetoothGatt == null)
                    return;
                BluetoothGattService serv = bluetoothGatt.getService(uuid_serv);
                if (serv == null) {
                    writeQueue.issue();
                    return;
                }
                BluetoothGattCharacteristic chara = serv.getCharacteristic(uuid_conf);
                if (chara == null) {
                    writeQueue.issue();
                    return;
                }
                bluetoothGatt.readCharacteristic(chara);
            }
        });
    }

    /// Callback for disconnection.
    protected abstract void onDisconnected(boolean byRemote);

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public boolean setMTU(int mtu) {
        int retry = 5;
        while (retry > 0) {
            retry = (bluetoothGatt.requestMtu(mtu) ? -1 : retry - 1);
        }
        return retry < 0;
    }

    /// Thread to handle connection I/O
    private class ConnectionThread extends Thread {
        private final BluetoothSocket socket;
        private final InputStream input;
        private final OutputStream output;
        private boolean requestedClosing = false;

        ConnectionThread(BluetoothSocket socket) {
            this.socket = socket;
            InputStream tmpIn = null;
            OutputStream tmpOut = null;

            try {
                tmpIn = socket.getInputStream();
                tmpOut = socket.getOutputStream();
            } catch (IOException e) {
                e.printStackTrace();
            }

            this.input = tmpIn;
            this.output = tmpOut;
        }

        /// Thread main code
        public void run() {
            byte[] buffer = new byte[1024];
            int bytes;

            while (!requestedClosing) {
                try {
                    bytes = input.read(buffer);

                    onRead(Arrays.copyOf(buffer, bytes));
                } catch (IOException e) {
                    // `input.read` throws when closed by remote device
                    break;
                }
            }

            // Make sure output stream is closed
            if (output != null) {
                try {
                    output.close();
                } catch (Exception e) {
                }
            }

            // Make sure input stream is closed
            if (input != null) {
                try {
                    input.close();
                } catch (Exception e) {
                }
            }

            // Callback on disconnected, with information which side is closing
            onDisconnected(!requestedClosing);

            // Just prevent unnecessary `cancel`ing
            requestedClosing = true;
        }

        /// Writes to output stream
        public void write(byte[] bytes) {
            try {
                output.write(bytes);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        /// Stops the thread, disconnects
        public void cancel() {
            if (requestedClosing) {
                return;
            }
            requestedClosing = true;

            // Flush output buffers befoce closing
            try {
                output.flush();
            } catch (Exception e) {
            }

            // Close the connection socket
            if (socket != null) {
                try {
                    // Might be useful (see https://stackoverflow.com/a/22769260/4880243)
                    Thread.sleep(111);

                    socket.close();
                } catch (Exception e) {
                }
            }
        }
    }

    private final BluetoothGattCallback btCallback = new BluetoothGattCallback() {
        @Override
        public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
            Message m = new Message();
            Bundle bundle = new Bundle();
            String s = "";
            if (status != BluetoothGatt.GATT_SUCCESS) {// !=0 //133 is GATT_ERROR
                s = "Connect Fail-" + gatt.getDevice().getAddress() + "\nState:" + status + "/" + newState;
            } else
                switch (newState) {
                    case BluetoothProfile.STATE_CONNECTED:// ==2
                        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP)
                            gatt.discoverServices();
                        else if (!setMTU(512)) { // Default:23(20+3)/max:512(509+3)
                            gatt.discoverServices();
                        }
                        return;
                    case BluetoothProfile.STATE_DISCONNECTED:// ==0
                        s = "Off Line-" + gatt.getDevice().getAddress() + "\nState:" + status + "/" + newState;
                        gatt.close();
                        break;
                }
            if (bluetoothGatt != null) {
                bluetoothGatt.disconnect();
                bluetoothGatt = null;
                bundle.putString("msg", s);
                m.setData(bundle);
            }
            m.what = 400;
            handler.sendMessage(m);// post message
        }

        @Override
        public void onServicesDiscovered(BluetoothGatt gatt, int status) {
            if (status != BluetoothGatt.GATT_SUCCESS)
                return;
            handler.sendEmptyMessage(200);
            writeQueue.flush();
            rxValue = new byte[] {};
            read(UUID_180A_SERV, UUID_180A_VER);// Read FirmwareVersion
        }

        @Override
        public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {
            byte[] data = characteristic.getValue();// Got Notify
            byte[] tmpBuf = new byte[rxValue.length + data.length];
            System.arraycopy(rxValue, 0, tmpBuf, 0, rxValue.length);
            System.arraycopy(data, 0, tmpBuf, rxValue.length, data.length);
            rxValue = tmpBuf.clone();
            handler.sendEmptyMessage(500);// Refresh Display
        }

        @Override
        public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
            writeQueue.issue();
            if (status != BluetoothGatt.GATT_SUCCESS)
                return;
            UUID uuid = characteristic.getUuid();
            txValue = characteristic.getValue();
            if (UUID_180A_VER.equals(uuid)) {// Got FirmwareVersion
                handler.sendEmptyMessage(210);
            } else if (UUID_BLE5NAME.equals(uuid)) {// Got DeviceName
                handler.sendEmptyMessage(540);
            }
        }

        @Override
        public void onCharacteristicWrite(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
            super.onCharacteristicWrite(gatt, characteristic, status);
            writeQueue.issue();
        }

        @Override
        public void onDescriptorRead(BluetoothGatt gatt, BluetoothGattDescriptor descriptor, int status) {
            super.onDescriptorRead(gatt, descriptor, status);
        }

        @Override
        public void onDescriptorWrite(BluetoothGatt gatt, BluetoothGattDescriptor descriptor, int status) {
            super.onDescriptorWrite(gatt, descriptor, status);
            writeQueue.issue();
        }

        @Override
        public void onReadRemoteRssi(BluetoothGatt gatt, int rssi, int status) {
            super.onReadRemoteRssi(gatt, rssi, status);
        }

        @Override
        public void onReliableWriteCompleted(BluetoothGatt gatt, int status) {
            super.onReliableWriteCompleted(gatt, status);
        }

        @Override
        public void onMtuChanged(BluetoothGatt gatt, final int mtu, int status) {
            super.onMtuChanged(gatt, mtu, status);
            gatt.discoverServices();
        }
    };

    public void setNotify(final boolean enable) {
        writeQueue.queueRunnable(new Runnable() {
            @Override
            public void run() {
                if (bluetoothGatt == null)
                    return;
                BluetoothGattService serv = bluetoothGatt.getService(UUID_BLE_SERV);
                if (serv == null) {
                    writeQueue.issue();
                    return;
                }

                BluetoothGattCharacteristic config = serv.getCharacteristic(UUID_BLE5DATA);
                if (config == null) {
                    writeQueue.issue();
                    return;
                }
                bluetoothGatt.setCharacteristicNotification(config, enable);
                BluetoothGattDescriptor configurCCC = config.getDescriptor(UUID_NOTIFY);
                if (configurCCC == null) {
                    writeQueue.issue();
                    return;
                }
                configurCCC.setValue(enable ? BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE
                        : BluetoothGattDescriptor.DISABLE_NOTIFICATION_VALUE);
                bluetoothGatt.writeDescriptor(configurCCC);
            }
        });
    }

    private Handler initMessage() {
        return new Handler(new Handler.Callback() {
            public boolean handleMessage(Message msg) {
                String s = "";
                int i;
                Bundle bundle = msg.getData();
                switch (msg.what) {
                    case 100:// Connecting
                        break;
                    case 200:// Connected
                        break;
                    case 300:// Reboot
                        break;
                    case 400:// Connect fail
                        break;
                    case 210:// Display FirmwareVersion
                        break;
                    case 220:// Got DeviceName
                        break;
                    case 230:// Got ble version
                        break;
                    case 500:// Display Notify Data
                        onRead(rxValue);
                        break;

                    case 530:// Peripheral Address
                        break;
                    case 540:// Name
                        break;

                    case 525:// RS232 (Nordic)
                        break;

                    case 565:// PIN code
                        break;

                }// end switch
                return false;
            }
        });
    }
}
