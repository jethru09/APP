-- Clean, idempotent schema for the `octacore` database
CREATE DATABASE IF NOT EXISTS octacore DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE octacore;

-- Core tables used by t2.py. All tables created with IF NOT EXISTS to avoid errors
CREATE TABLE IF NOT EXISTS Block(
    Block_name VARCHAR(64) NOT NULL,
    PRIMARY KEY(Block_name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Phone(
    Work VARCHAR(32) NOT NULL,
    Home VARCHAR(32),
    Emergency VARCHAR(32),
    PRIMARY KEY(Work)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Teaching_staff(
    Faculty_ID VARCHAR(32) NOT NULL,
    FirstName VARCHAR(64) NOT NULL,
    MiddleName VARCHAR(64),
    LastName VARCHAR(64) NOT NULL,
    Email VARCHAR(128) NOT NULL,
    PRIMARY KEY(Faculty_ID),
    UNIQUE KEY ux_teaching_email (Email)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS NTeaching_staff (
    Staff_ID VARCHAR(32) NOT NULL,
    F_name VARCHAR(64) NOT NULL,
    M_name VARCHAR(64),
    L_name VARCHAR(64) NOT NULL,
    EmailID VARCHAR(128),
    PRIMARY KEY(Staff_ID),
    UNIQUE KEY ux_nteaching_email (EmailID)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Job_desc(
    Discipline_name VARCHAR(128) NOT NULL,
    Designation VARCHAR(128) NOT NULL,
    Room_number VARCHAR(32) NOT NULL,
    Building VARCHAR(64) NOT NULL,
    PRIMARY KEY (Discipline_name,Designation,Room_number,Building),
    KEY idx_job_designation (Designation),
    KEY idx_job_discipline (Discipline_name),
    KEY idx_job_room (Room_number),
    KEY idx_job_building (Building)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Students(
    Roll_number VARCHAR(32) NOT NULL,
    First_name VARCHAR(64) NOT NULL,
    Middle_name VARCHAR(64),
    Last_name VARCHAR(64) NOT NULL,
    Email_id VARCHAR(128) NOT NULL,
    Discipline VARCHAR(128) NOT NULL,
    Program VARCHAR(64) NOT NULL,
    PRIMARY KEY(Roll_number),
    UNIQUE KEY ux_students_email (Email_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Facility (
    Facility_name VARCHAR(128) NOT NULL,
    RoomNumber VARCHAR(32),
    BuildingName VARCHAR(64) NOT NULL,
    Email_addr VARCHAR(128),
    PRIMARY KEY(Facility_name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Contact(
    Work VARCHAR(32) NOT NULL,
    Faculty_ID VARCHAR(32) NOT NULL,
    PRIMARY KEY(Faculty_ID,Work),
    CONSTRAINT fk_contact_faculty FOREIGN KEY(Faculty_ID) REFERENCES Teaching_staff(Faculty_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_contact_phone FOREIGN KEY(Work) REFERENCES Phone(Work) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Contact_enquiry(
    Work VARCHAR(32) NOT NULL,
    Staff_ID VARCHAR(32) NOT NULL,
    PRIMARY KEY(Staff_ID,Work),
    CONSTRAINT fk_contact_enq_staff FOREIGN KEY(Staff_ID) REFERENCES NTeaching_staff(Staff_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_contact_enq_phone FOREIGN KEY(Work) REFERENCES Phone(Work) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Contact_info(
    Work VARCHAR(32) NOT NULL,
    Facility_name VARCHAR(128) NOT NULL,
    PRIMARY KEY(Facility_name,Work),
    CONSTRAINT fk_contact_info_facility FOREIGN KEY(Facility_name) REFERENCES Facility (Facility_name) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_contact_info_phone FOREIGN KEY(Work) REFERENCES Phone(Work) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Contact_number(
    Work VARCHAR(32) NOT NULL,
    Roll_number VARCHAR(32) NOT NULL,
    PRIMARY KEY(Roll_number,Work),
    CONSTRAINT fk_contactnum_phone FOREIGN KEY(Work) REFERENCES Phone(Work) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_contactnum_student FOREIGN KEY(Roll_number) REFERENCES Students(Roll_number) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS To_Contact(
    Block_name VARCHAR(64) NOT NULL,
    Work VARCHAR(32) NOT NULL,
    PRIMARY KEY(Block_name,Work),
    CONSTRAINT fk_tocontact_phone FOREIGN KEY(Work) REFERENCES Phone(Work) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_tocontact_block FOREIGN KEY(Block_name) REFERENCES Block(Block_name) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Work_info(
    Staff_ID VARCHAR(32) NOT NULL,
    Designation VARCHAR(128) NOT NULL,
    Room_number VARCHAR(32) NOT NULL,
    Building VARCHAR(64) NOT NULL,
    Discipline_name VARCHAR(128) NOT NULL,
    PRIMARY KEY (Discipline_name,Designation,Room_number,Building,Staff_ID),
    CONSTRAINT fk_workinfo_jobdesc FOREIGN KEY (Discipline_name,Designation,Room_number,Building)
        REFERENCES Job_desc(Discipline_name,Designation,Room_number,Building) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_workinfo_staff FOREIGN KEY (Staff_ID) REFERENCES NTeaching_staff (Staff_ID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Specialization(
    Faculty_ID VARCHAR(32) NOT NULL,
    Discipline_name VARCHAR(128) NOT NULL,
    Designation VARCHAR(128) NOT NULL,
    Room_number VARCHAR(32) NOT NULL,
    Building VARCHAR(64) NOT NULL,
    PRIMARY KEY (Discipline_name,Designation,Room_number,Building,Faculty_ID),
    CONSTRAINT fk_spec_jobdesc FOREIGN KEY (Discipline_name,Designation,Room_number,Building)
        REFERENCES Job_desc(Discipline_name,Designation,Room_number,Building) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_spec_faculty FOREIGN KEY (Faculty_ID) REFERENCES Teaching_staff (Faculty_ID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Users table used for authentication in t2.py
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(128) UNIQUE,
    password_hash CHAR(64)
) ENGINE=InnoDB;

-- (Indexes can be created manually if desired; omitted to keep SQL compatible)

-- Minimal seed data so the app has something to show and joins succeed
INSERT IGNORE INTO Phone (Work, Home, Emergency) VALUES
    ('2573','1573', NULL),('2463','1463', NULL),('2538','1538', NULL),('2409','1409',NULL),
    ('9000000002', NULL, NULL),('9000000003', NULL, NULL);

INSERT IGNORE INTO Teaching_staff (Faculty_ID, FirstName, MiddleName, LastName, Email)
    VALUES ('cse1', 'Abhishek', NULL, 'Bichhawat', 'abhishek.b@iitgn.ac.in');

INSERT IGNORE INTO NTeaching_staff (Staff_ID, F_name, M_name, L_name, EmailID)
    VALUES ('n1', 'Anil', NULL, 'Kumar', 'anil.k@iitgn.ac.in');

INSERT IGNORE INTO Job_desc (Discipline_name, Designation, Room_number, Building)
    VALUES ('Computer Science and Engineering', 'Assistant Professor', '405A', 'AB13'),
                 ('Hospitality', 'Junior Accounts Assistant', '308', 'AB3');

INSERT IGNORE INTO Specialization (Faculty_ID, Discipline_name, Designation, Room_number, Building)
    VALUES ('cse1', 'Computer Science and Engineering', 'Assistant Professor', '405A', 'AB13');

INSERT IGNORE INTO Work_info (Staff_ID,Designation,Room_number,Building,Discipline_name)
    VALUES ('n1', 'Junior Accounts Assistant', '308', 'AB3', 'Hospitality');

INSERT IGNORE INTO Students (Roll_number, First_name, Middle_name, Last_name, Email_id, Discipline, Program)
    VALUES ('20110002', 'Abhishek', 'Balaji', 'Mungekar', 'abhishek.mungekar@iitgn.ac.in', 'Mechanical Engineering', 'Btech');

INSERT IGNORE INTO Facility (Facility_name, RoomNumber, BuildingName, Email_addr)
    VALUES ('Library 1', '107', 'AB3', 'library@iitgn.ac.in');

INSERT IGNORE INTO Contact (Work, Faculty_ID) VALUES ('2573', 'cse1');
INSERT IGNORE INTO Contact_enquiry (Work, Staff_ID) VALUES ('2463', 'n1');
INSERT IGNORE INTO Contact_number (Work, Roll_number) VALUES ('9000000002', '20110002');
INSERT IGNORE INTO Contact_info (Work, Facility_name) VALUES ('2573', 'Library 1');
INSERT IGNORE INTO Block (Block_name) VALUES ('Hostel-G');
INSERT IGNORE INTO To_Contact (Block_name, Work) VALUES ('Hostel-G', '9000000002');

-- Keep the file idempotent and avoid running fragile administrative statements
