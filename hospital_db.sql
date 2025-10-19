-- === STEP 0: CREATE AND USE DATABASE ===
CREATE DATABASE IF NOT EXISTS hospital_db;
USE hospital_db;

-- === STEP 1: CREATE PATIENTS TABLE ===
CREATE TABLE IF NOT EXISTS patients (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100),
    patient_room VARCHAR(10)
);

-- === STEP 2: CREATE MEDICINE LOG TABLE ===
CREATE TABLE IF NOT EXISTS medicine_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    dispenser_number INT CHECK (dispenser_number IN (1, 2)),  -- Only allow dispenser 1 or 2
    medicine_name VARCHAR(100),
    time_medicine_given TIME,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

-- === STEP 3: INSERT 10 SAMPLE PATIENTS ===
INSERT INTO patients (patient_id, patient_name, patient_room) VALUES
(1, 'Alice Smith', '101A'),
(2, 'Bob Johnson', '102B'),
(3, 'Charlie Kim', '103A'),
(4, 'Diana Ray', '104C'),
(5, 'Edward Lee', '105B'),
(6, 'Fiona Green', '106A'),
(7, 'George Hall', '107B'),
(8, 'Hannah Brown', '108C'),
(9, 'Isaac Miller', '109A'),
(10, 'Julia Davis', '110B');

-- === STEP 4: INSERT 10 RANDOM SAMPLE MEDICINE LOGS ===
INSERT INTO medicine_log (patient_id, dispenser_number, medicine_name, time_medicine_given) VALUES
(1, 1, 'Aspirin', '08:00:00'),
(2, 2, 'Ibuprofen', '08:30:00'),
(3, 1, 'Paracetamol', '09:00:00'),
(4, 2, 'Metformin', '09:30:00'),
(5, 1, 'Lisinopril', '10:00:00'),
(6, 2, 'Omeprazole', '10:30:00'),
(7, 1, 'Amoxicillin', '11:00:00'),
(8, 2, 'Atorvastatin', '11:30:00'),
(9, 1, 'Prednisone', '12:00:00'),
(10, 2, 'Levothyroxine', '12:30:00');

-- === STEP 5: VIEW JOINED DATA ===
SELECT 
    p.patient_name,
    p.patient_id,
    p.patient_room,
    m.dispenser_number,
    m.medicine_name,
    m.time_medicine_given
FROM 
    medicine_log m
JOIN 
    patients p ON m.patient_id = p.patient_id;
    