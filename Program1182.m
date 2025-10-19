% === ADD JDBC DRIVER (macOS path) ===
javaaddpath('/Users/dharvik/Downloads/mysql-connector-j-9.2.0/mysql-connector-j-9.2.0.jar');

% === MYSQL SETTINGS ===
dbname = 'hospital_db';
username = 'root';
password = 'Sho@18Gup07';
server = 'localhost';
port = 3306;

% === ARDUINO SETTINGS ===
comPort = "/dev/tty.usbmodem11301";
boardType = 'Mega2560';

% === CONNECT TO MYSQL ===
jdbcURL = 'jdbc:mysql://localhost:3306/hospital_db';
conn = database(dbname, username, password, 'com.mysql.cj.jdbc.Driver', jdbcURL);

if isopen(conn)
    disp("Connected to MySQL.");
else
    error("Could not connect to MySQL. Check server, credentials, or JDBC path.");
end

% === CONNECT TO ARDUINO ===
try
    a = arduino(comPort, boardType, 'Libraries', 'Servo');
    disp("Arduino connected.");
catch
    error("Failed to connect to Arduino. Check your USB port and board type.");
end

% === SETUP SERVO ===
mainServo = servo(a, 'D9');

% === MAIN DISPENSING LOOP ===
while true
    % === GET USER INPUT ===
    patient_id = input('Patient ID: ');
    patient_name = input('Patient Name: ', 's');
    patient_room = input('Patient Room: ', 's');
    medicine_name = input('Medicine Name: ', 's');
    pill_count = input('Number of pills to dispense (1 to 3): ');

    disp('Enter time in exact format: HH:MM:SS (e.g., 07:09:00) - MILITARY FORMAT:');
    time_input = input('Time to dispense (HH:MM:SS): ', 's');

    % === VALIDATE TIME FORMAT ===
    try
        time_target = datetime(time_input, 'InputFormat', 'HH:mm:ss');
        time_target_str = datestr(time_target, 'HH:MM:SS');
    catch
        error("Invalid time format. Use HH:MM:SS (e.g., 07:09:00)");
    end

    % === INSERT PATIENT IF NEW ===
    query = sprintf('SELECT * FROM patients WHERE patient_id = %d', patient_id);
    existing = fetch(conn, query);

    if isempty(existing)
        insert(conn, 'patients', {'patient_id', 'patient_name', 'patient_room'}, ...
            {patient_id, patient_name, patient_room});
        disp("New patient added.");
    else
        disp("Patient already exists.");
    end

    % === INSERT MEDICINE LOG ===
    insert(conn, 'medicine_log', ...
        {'patient_id', 'dispenser_number', 'medicine_name', 'time_medicine_given'}, ...
        {patient_id, 1, medicine_name, time_input});
    disp("Medicine log entry saved.");

    % === WAIT UNTIL EXACT DISPENSE TIME ===
    disp("Waiting until exact scheduled time...");

    while true
        now_time = datetime('now');
        now_str = datestr(now_time, 'HH:MM:SS');

        fprintf("Current time: %s | Waiting for: %s\n", now_str, time_target_str);

        if strcmp(now_str, time_target_str)
            disp("Exact time matched. Beginning dispensing...");
            break;
        end

        pause(1);
    end

    % === DISPENSE PILLS USING ARDUINO-STYLE MOVEMENT ===
    fprintf('\nDispensing %d pill(s)...\n', pill_count);
    for i = 1:pill_count
        writePosition(mainServo, 0.5); pause(1);   % Move to 90°
        writePosition(mainServo, 0);   pause(1);   % Move to 0°
        writePosition(mainServo, 0.5); pause(1);   % Return to 90°
        fprintf("Pill %d dispensed.\n", i);
    end

    % === ASK TO CONTINUE OR EXIT ===
    again = input('Would you like to dispense more pills? (y/n): ', 's');
    if lower(again) ~= 'y'
        break;
    end
end

% === CLEANUP ===
close(conn);
clear a;
disp("Done. System cleaned up.");