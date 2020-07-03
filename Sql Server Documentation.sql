/*
 There is two type of database:
 - user define database: created by user.
 - system database: they are preinstall in sql
 */
-- ###creating a database using query### --
create database school;
/*
   When the database is created there is a  .mdf (Data File which conain actual data)
   and .ldf (Transaction Log file used for database recover) file that are created
*/

-- ###Rename Database using query###--
Alter Database school Modify Name= SchoolManagement;
-- ###Rename Database stored procedure###--
Execute sp_renamedb SchoolManagement, UniversityManagement;
-- ###Drop Database using query###--
drop database UniversityManagement;
--	To delete a database which is in a network you have to change it to single user mode--
alter database UniversityManagement set SINGLE_USER with rollback immediate;
--rollback immediate mean if there is an incomplete transaction roll them back and close the database connection--

-- Creating a table using query--
Use [UniversityManagement]
Go
Create Table tbStudent
(
 ID int NOT NULL Primary Key,
 Name nvarchar(50) NOT NULL,
 Email nvarchar(50) NOT NULL,
 GenderId int NULL
);
create table tblGender
(
 ID int NOT NULL Primary Key,
 Gender nvarchar(50) NOT NULL
);

--Modify a column contraint in sql table--
Alter table tbStudent add constraint tbStudent_GenderId_FK Foreign key (GenderId) references tblGender(ID);

select * from tblGender;
select * from tbStudent;

-- Insert data in a table using query--
Insert into tbStudent (ID, Name, Email) values(4, 'Mike', 'mike@mail.com');

--Create a default value constraint: When data is inserted and GenderId is not supply we should provide a default value--
alter table tbStudent add constraint DFV_tbStudent_GenderId default 3 for GenderId;
--Insert data without the defaut value--
Insert into tbStudent (ID, Name, Email) values(4, 'Mike', 'mike@mail.com');
--Insert data with with a colomun which has default value set to NULL--
Insert into tbStudent (ID, Name, Email, GenderId) values(5, 'Mike', 'mike@mail.com', NULL);
-- Drop a table constraint--
Alter table tbStudent drop constraint DFV_tbStudent_GenderId;

--Delete table recode based on id--
delete from tblGender where ID = 3;
/*
   1. If you detele a foreign key colomun that has a default constraint and its detelete cascading referential 
      integrety is set to "Set Default", all the table row referecing it will bed change to a default constraint value.

   2. If you detele a foreign key colomun that has a default constraint and its detelete  cascading referential 
      integrety is set to "Set Null", all the table row referecing it will be changed to a Null.

   3. If you detele a foreign key colomun that has a default constraint and its detelete cascading referential 
      integrity is set to "Cascading", all the table row referecing it will deleted.
*/
--Set a cascading referencial integreity using query--
Alter table tbStudent add constraint tbStudent_cascade_GenderId_FK 
Foreign key (GenderId) references tblGender(ID) on delete cascade on update cascade;

--Check constraint--
Create Table tbStudent
(
 ID int NOT NULL Primary Key,
 Name nvarchar(50) NOT NULL,
 Email nvarchar(50) NOT NULL,
 GenderId int NULL,
 Age int NULL
);
Select * from tbStudent;
Insert into tbStudent (ID, Name, Email, GenderId, Age) values(3, 'Sarah', 'sarah@mail.com', 1, -80);
-- Add check constraint--
alter table tbStudent add constraint CK_tnStudent_Age Check (Age > 0 AND Age < 150);
--Check constraint can accept NULL value because it boolean expression will return an unknow result--
Insert into tbStudent (ID, Name, Email, GenderId, Age) values(1, 'Sarah', 'john@mail.com', 1, NULL);

--Identity--
Create Table tblTeacher
(
 ID int NOT NULL Primary Key identity(1,1),
 Name nvarchar(50) NOT NULL,
 Email nvarchar(50) NOT NULL,
 GenderId int NULL,
 Age int NULL
);
select * from tblTeacher;
insert into tblTeacher values('martin', 'martin@mail.com', 1, 50);
delete from tblTeacher where ID = 1;
--set the identity insert to on to allow passing the identity value while inserting data--
set identity_insert tblTeacher on;
set identity_insert tblTeacher off;
insert into tblTeacher (ID, Name, Email, GenderId, Age) values (1,'Kevin', 'kevin@mail.com', 1, 40);
--reset identity column value when all the table row have been deleted--
use [UniversityManagement];
go
select * from tblTeacher;
delete from tblTeacher;
insert into tblTeacher values ('Kevin', 'kevin@mail.com', 1, 40);
dbcc CHECKIDENT(tblTeacher, RESEED, 0);

--Retrieve the last identity generated--
Create Table Test1
(
	Id int primary key identity,
	Name nvarchar(50) NOT NULL
);
Create Table Test2
(
	Id int primary key identity,
	Name nvarchar(50) NOT NULL
);
insert into Test1 values('bbb');
select SCOPE_IDENTITY(); 
select @@IDENTITY;

--create a trigger that insert a row in Test2 whenever you insert one row in Test1--
create trigger trForTest1 on Test1 for insert
as
begin
	insert into Test2 values('aaaa');
end
select * from Test1;
select * from Test2;
select SCOPE_IDENTITY(); --return the last identity generated in the same session and same scope--
select @@IDENTITY; --return the last identity generated in the same session and accross any scope--
select IDENT_CURRENT('Test2'); --return the last identity generated in the any session and any scope--

--###Unique key constraint###--
/*
 unique key can be used when we want to enforce uniqueness of a column. Even primary key can be used but the different are following
 - A table can only have one primary key. A primary key cannot be null.
 - A table can have multiple unique key. One and only one null unique row can be allow across a table.
*/
create table tblPerson
(
	Id int primary key identity(1,1),
	Name nvarchar(50) not null,
	Email nvarchar(50) not null,
	GenderId int foreign key (GenderId) references tblGender(ID),
	Age int null,
);
alter table tblPerson add City nvarchar(50);

--create a unique key constraint using query--
alter table tblPerson add constraint UQ_tblPerson_Email unique(Email);
insert into tblPerson values('aaa', 'a@a.com', 1, 30);
insert into tblPerson values('bbbb', 'a@a.com', 2, 50); --This one will fail since we already have a@a.com as email in tblPerson--

--###select Statement###--
select * from tblPerson; --Display all the result--
select distinct City from tblPerson; --select distinct row--
select distinct City, Name from tblPerson; --The name column will override the distinct keyword and display the entire table--
select * from tblPerson where City = 'Tokyo'; --select data based on egal condition--
select * from tblPerson where City <> 'Tokyo'; --select data based on not egal condition--
select * from tblPerson where City != 'Tokyo'; --select data based on not egal condition--
select * from tblPerson where Age in (20, 70, 10); --select persons with age = 70, 20 and 10. IN operator take a list as a condition--
select * from tblPerson where Age between 10 and 30;--Select persons with age between 10 and 30--
select * from tblPerson where City like 'L%'; --Select all persons with the city start with L. LIKE operator take a patern as a condition. % is called wilcard--
select * from tblPerson where Email like '%@%'; --Select all persons with the email start with any character an @ in between then end with any characters --
select * from tblPerson where Email not like '%@%';--Select invalid email address--
select * from tblPerson where Email  like '_@_.com';--Select  email which has one character before @ and one character after a then .com--
select * from tblPerson where Name like '[JMG]%'; --Select people whose name start with A, J or M and follow with one or more character--
select * from tblPerson where Name like '[^JMG]%'; --Select people whose name start doesnot A, J or M and follow with one or more character--
select * from tblPerson where (City = 'London' or City = 'Tokyo') and Age > 25; --Select all person who live in London or Tokyo and Ageis greater than 25--
select * from tblPerson  order by Name;--Order the result by Name in ascending order--
select * from tblPerson  order by Name desc;--Order the result by Name in descending order--
select top 3 Name, Age from tblPerson; --select 3 row with Name and Age column--
select top 2 * from tblPerson; --select 3 row with all column--
--Select the oldest person in person table using query combination--
select top 1 * from tblPerson order by Age desc;

--###Group by statement###--
-----Aggregate function----
create table tblEmployee
(
	Id int primary key identity(1,1),
	Name nvarchar(50) not null,
	Email nvarchar(50) not null,
	GenderId int foreign key (GenderId) references tblGender(ID),
	Age int null,
	City nvarchar(50) not null,
	Salary int not null
);
select * from tblEmployee;
select SUM(Salary) from tblEmployee; --select the sum of all the employee salary--
select MIN(Salary) from tblEmployee; --select the minimum of all the employee salary--
select MAX(Salary) from tblEmployee; --select the maximum of all the employee salary--
select AVG(Salary) from tblEmployee; --select the minimum of all the employee salary--
select count(*) from tblEmployee; --count the number of records in a employee table--

select City, sum(Salary) as TotalSalary from tblEmployee group by City; --Group result by city and sum salary across all the city--
select City, GenderId, sum(Salary) as TotalSalary from tblEmployee group by City, GenderId; --Group result by city and gender and sum salary across all the city--
select City, GenderId, sum(Salary) as TotalSalary, count(*) as [Total Employee] from tblEmployee group by City, GenderId; --Group and count result by city and gender and sum salary across all the city--
--Group and count result by city and gender and sum salary across all the city where gender is 2.
 Here where statement is done before aggregation function. 
 where can be used with select, insert, delete, update. 
 Aggregate are not use in where
--
select City, GenderId, sum(Salary) as TotalSalary, count(*) as [Total Employee] from tblEmployee where GenderId = 2 group by City, GenderId; 
select City, count(*) from tblEmployee where sum(Salary) > 2000 group by City; --Connot work because of where filter the record before runing aggreagete function--
--
  Group and count result by city and gender and sum salary across all the city where gender is 2. 
  Here having statement is execute after the aggreation statement. 
  having can be used only on select 
--
select City, GenderId, sum(Salary) as TotalSalary, count(*) as [Total Employee] from tblEmployee group by City, GenderId having GenderId = 2; 
select City, count(*) from tblEmployee  group by City having sum(Salary) > 2000; --work since having retrieve all the record then run aggregate function--

--###Join Statement###--
select * from tblEmployee;
select * from tblGender;
select Name, Email, Gender, Age, City, Salary from tblEmployee join tblGender on tblEmployee.GenderId = tblGender.ID;

--Cross Join--
--Cross join make a cartesian product of all the two table. mutiply the number of row of the two table--
select Name, Email, Gender, Age, City, Salary from tblEmployee cross join tblGender;

--Inner Join--
--Return only mathing row between the 2 tables--
select Name, Email, Gender, Age, City, Salary from tblEmployee inner join tblGender on tblEmployee.GenderId = tblGender.ID;

--Outer Join(left, right, full)--
--Left outer join return match and no match result from the left table--
select Name, Email, Gender, Age, City, Salary from tblEmployee left outer join tblGender on tblEmployee.GenderId = tblGender.ID;
select Name, Email, Gender, Age, City, Salary from tblEmployee left join tblGender on tblEmployee.GenderId = tblGender.ID;

--Right outer join return match and no match result from the right table--
select Name, Email, Gender, Age, City, Salary from tblEmployee right outer join tblGender on tblEmployee.GenderId = tblGender.ID;
select Name, Email, Gender, Age, City, Salary from tblEmployee right join tblGender on tblEmployee.GenderId = tblGender.ID;

--Full out join return match and no match data of the two table--
select Name, Email, Gender, Age, City, Salary from tblEmployee  FULL OUTER join tblGender on tblEmployee.GenderId = tblGender.ID;
select Name, Email, Gender, Age, City, Salary from tblEmployee  full join tblGender on tblEmployee.GenderId = tblGender.ID;

--##Advanced or intelligent joins in sql server##--
--select only the none matching row from the left table--
select Name, Email, Gender, Age, City, Salary from tblEmployee left outer join tblGender on tblEmployee.GenderId = tblGender.ID where tblEmployee.GenderId is NULL;

--select only the none matching row from the right table--
select Name, Email, Gender, Age, City, Salary from tblEmployee right outer join tblGender on tblEmployee.GenderId = tblGender.ID where tblEmployee.GenderId is NULL;

--select only the none matching row from the two table table--
select Name, Email, Gender, Age, City, Salary from tblEmployee full join tblGender on tblEmployee.GenderId = tblGender.ID where tblEmployee.GenderId is NULL or tblEmployee.Id is Null;
--When compairing value to a NULL in sql you have to use IS operator--

--##Self join in sql server##--
--Inner self join one same table--
create table Spies
(
	Id int primary key identity(1,1),
	Name nvarchar(50) not null,
	Email nvarchar(50) not null,
	City nvarchar(50) not null,
	Handler int foreign key references Spies(Id) null
);
--left self join--
select S.Name as [Employee Name], H.Name AS [Handler Name] from Spies S left join Spies H on S.Handler = H.Id;

--right self join--
select S.Name as [Employee Name], H.Name AS [Handler Name] from Spies S right join Spies H on S.Handler = H.Id;

--full self join--
select S.Name as [Employee Name], H.Name AS [Handler Name] from Spies S full join Spies H on S.Handler = H.Id;

--inner self join--
select S.Name as [Employee Name], H.Name AS [Handler Name] from Spies S inner join Spies H on S.Handler = H.Id;

--##Different ways to replace NULL in sql server ##--
--Replace NULL using ISNULL function--
select ISNULL(NULL, 'No Handler') as [Handler Name];
select S.Name as [Employee Name], ISNULL(H.Name, 'No Handler') AS [Handler Name] from Spies S left join Spies H on S.Handler = H.Id;

--Replace NULL using COALESCE function--
select COALESCE(NULL, 'No Handler') as [Handler Name];
select S.Name as [Employee Name], COALESCE(H.Name, 'No Handler') AS [Handler Name] from Spies S left join Spies H on S.Handler = H.Id;

--Replace NULL using CASE statement--
select S.Name as [Employee Name], CASE WHEN H.Name IS NULL THEN 'No Handler' ELSE H.Name END AS [Handler Name] from Spies S left join Spies H on S.Handler = H.Id;

--##Coalesce function in sql server ##--
--Coalesce return only first non null value--
create table Family
(
	Id int primary key identity(1,1),
	FirstName nvarchar(50)  null,
	MiddleName nvarchar(50) null,
	LastName nvarchar(50)  null,
);
insert into Family(FirstName) values('John');
insert into Family(MiddleName) values('Raymond');
insert into Family(LastName) values('Kim');
--It will return the firstname if it is not null or the middle name if the firstname is null or the lastname if the first and middle name are null--
select * from Family;
select Id, COALESCE(FirstName, MiddleName, LastName) as Names from Family;

--##Union and union all in sql server##--
create table tblIndianCustomer
(
 Id int primary key identity(1,1),
 Name nvarchar(50)not null,
 Email nvarchar(50) not null
 );
 create table tblJapaneseCustomer
(
 Id int primary key identity(1,1),
 Name nvarchar(50)not null,
 Email nvarchar(50) not null
 );
 select * from tblIndianCustomer; 
 select * from tblJapaneseCustomer;
--union all (Doesnot remove duplicated row)--

select Id, Name, Email from tblIndianCustomer
UNION ALL
select Id, Name, Email from tblJapaneseCustomer;
--Union (It removes the duplicated row from the two table)--

select Id, Name, Email from tblIndianCustomer
UNION
select Id, Name, Email from tblJapaneseCustomer;
--Sort data of UNION ALL using ORDER BY--

select Id, Name, Email from tblIndianCustomer
UNION ALL
select Id, Name, Email from tblJapaneseCustomer order by Name;

--Sort data of UNION using ORDER BY --
select Id, Name, Email from tblIndianCustomer
UNION
select Id, Name, Email from tblJapaneseCustomer order by Name;

--##Stored procedures in sql server##--
create procedure spGetPersons --you can say create proc or create procedure--
as
Begin
	select Id, Name, Email, City from tblPerson
end
--Execute stored procedure--
spGetPersons;
exec spGetPersons;
execute spGetPersons;

--Stored Procedure with parameters--
create proc spStudent 
@GenderId int
as 
begin
	select ID, Name, Email, Age from tbStudent where GenderId = @GenderId
end
--Execute procedure with parameter--
exec spStudent 1;
exec spStudent @GenderId = 1;

--Get stored procedure source code using system stored procedure--
sp_helptext spStudent;

--alter stored procedure--
Alter proc spStudent 
@GenderId int
as 
begin
	select ID, Name, Email, Age from tbStudent where GenderId = @GenderId order by Name
end
--Delete a stored procedure--
drop procedure spStudent;

--Encrypt stored procedure source code--
alter procedure spGetPersons 
with encryption
as
Begin
	select Id, Name, Email, City from tblPerson
end
--Try to get stored procedure source code--
sp_helptext spGetPersons ;

--##Stored procedures with output parameters##--
create procedure spGetTeachers
@GenderId int,
@TeacherCount int output
as
begin
	select @TeacherCount = count(Id) from tblTeacher where GenderId = @GenderId
end

--Execute stored procedure with output parameter--
--Example 1--
Declare @TotalTeacher int
Execute spGetTeachers 1,  @TotalTeacher output
print @TotalTeacher;

--Example 2--
Declare @TotalTeachers int
Execute spGetTeachers 1,  @TotalTeachers output
if(@TotalTeachers is NULL)
	print '@TotalTeachers is null'
else
	print '@TatalTeachers is not null'

--Example 3--
Declare @Total_Teacher int
Execute spGetTeachers @TeacherCount = @Total_Teacher output, @GenderId = 1
print @Total_Teacher;

--System Stored Procedure--
--sp_help procedure work with any database object--
sp_help spGetTeachers; --Get information about a particular stored procedure--
sp_help tblTeacher; --Get information about a particular table--

--sp_depends checks  dependencies of a database table--
sp_depends spGetTeachers;
sp_depends tblTeacher;

--##Stored procedure output parameters or return value##--
--Stored procedure with  output parameter--
--Store procedure with output parameter return any type of data and can return multiple value--
create procedure spGetPersons1
@Id int,
@Name nvarchar(50) output
as
begin
	select @Name = Name from tblPerson where Id = @Id
end

--execute--
declare @PersonName1 nvarchar(50)
execute spGetPersons1 4, @PersonName1 output
print 'Name of the employee = '+ @PersonName1

--Stored procedure with  return value--
create procedure spGetPersons2
@Id int
as
begin
	return (select Name from tblPerson where Id = @Id)
end

--execute--
--Return stored procedure return only integer and can return only one value. it return 0 or 1 to specified if the store procedure execution fail or succeded--
declare @PersonName2 nvarchar(50)
execute @PersonName2 = spGetPersons2 1
print 'Name of the employee = '+ @PersonName2

--##Built in string functions in sql serve##--
--ASCII Function(convert a character to its ASCII code)--
select ASCII('a');

--CHAR Function(convert an ASCII code to it character)--
declare @start int;
set @start = 65;
while(@start <= 90)
begin
	print CHAR(@start)
	set @start = @start + 1
end

--LTRIM Function(Remove black to it left handside of a string)--
select '    Hello';
select LTRIM('   Hello');

--LTRIM Function(Remove black to it right handside of a string)--
select 'Hello    ';
select RTRIM('Hello    ');

--LTRIM and RTRIM--
select '     Hello     '+' '+'     World     ';
select RTRIM(LTRIM('  Hello  '))+' '+RTRIM(LTRIM('  World  '));

--LOWER and UPPER function(convert a string to upper or lowercase)--3
select UPPER('Hello');
select LOWER('HELLO');

--REVERSE function(Give a reverse string of the input string)--
select REVERSE('12345');

--LEN function(return a length of a give string)--
select LEN('Hello World');

--##LEFT, RIGHT, CHARINDEX and SUBSTRING functions in sql server##--
--LEFT function(Return the specified number of character from the left hand side of a given string)--
select LEFT('Hello World', 5);

--RIGHT function(Return the specified number of character from the right hand side of a given string)--
select RIGHT('Hello World', 5);

--CHARINDEX function(Return a starting position of a specified expression in a character string)--
select CHARINDEX('@', 'admin@mail.com', 1); --searching the index of @ starting at position 1--
select CHARINDEX('@', 'admin@mail.com'); --searching the index of @ starting at position 1 without specified position 1 since the default starting position will be on--

--SUBSTRING function(Return a part of a string from a give string)--
select SUBSTRING('admin@mail.com', 7, 8) --get a substring of 8 character from a string start a 7 position--

--Get a domaine name of the email using string function in sql--
select SUBSTRING('admin@mail.com', CHARINDEX('@', 'admin@mail.com') + 1, LEN('admin@mail.com') -  CHARINDEX('@', 'admin@mail.com'));

select SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email) -  CHARINDEX('@', Email)) as Domain, count(Email) from tblEmployee group by SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email) -  CHARINDEX('@', Email));

--##Replicate, Space, Patindex, Replace and Stuff string functions in sql server##--
--Replicate function(repeat a give string of a specified number of time)--
select REPLICATE('User ', 5);
select Name, SUBSTRING(Email, 1, 2)+REPLICATE('*', 5)+SUBSTRING(Email, CHARINDEX('@', Email), LEN(Email)-CHARINDEX('@', Email)+1)  from tblEmployee;

--Space function(return number of space specified by number of space argument)--
select 'Hello'+SPACE(10)+'World';
select Name+SPACE(10)+Email as [User] from tblEmployee;

--Patindex function(return a starting position of the first occurance of a patterner in a spacific expression)--
select Email, PATINDEX('%@mail.com', Email) as FirstOccurence from tblEmployee where PATINDEX('%@mail.com', Email) > 0;

--Replace function(Replace all occurances of a spacified string with another string)--
select Email, REPLACE(Email,'.com', '.net') as ReplacedEmail from tblEmployee;

--Stuff function(function inserts replacement expression at the starting position specified along with removing characters specified using Length parameter)--
select Name, STUFF(Email, 2, CHARINDEX('@', Email)-2, '*****') from tblEmployee;

--##DateTime functions in SQL Server##--
create table tblDateTime
(
	c_time time,
	c_date date,
	c_smalldatetime smalldatetime,
	c_datetime datetime,
	c_datetime2 datetime2,
	c_datetimeoffset datetimeoffset
);

insert into tblDateTime values(GETDATE(), GETDATE(), GETDATE(),GETDATE(), GETDATE(), GETDATE());
select * from tblDateTime;

--Datetime function--
select GETDATE() as 'GETDATE()';
select CURRENT_TIMESTAMP as 'CURRENT_TIMESTAMP';
select SYSDATETIME() as 'SYSDATETIME()';
select SYSDATETIMEOFFSET() as 'SYSDATETIMEOFFSET()';
select GETUTCDATE() as 'GETUTCDATE()';

--##IsDate, Day, Month, Year and DateName DateTime functions in SQL Server##--
--ISDATE function(Return 1 if it is a valide date and 0 if it is not a valide date)--
select ISDATE(GETDATE());
select ISDATE('DATE');
select ISDATE('2020-01-23 12:52:30.007');
select ISDATE('2020-01-23 21:51:21.0276694 +09:00'); --Return 0 since it has the date offset--

--DAY function(Return the day number of the month of a given date)--
select DAY(GETDATE());
select DAY('12/31/2019')

--MONTH function(Return the moth number of the year of a given date)--
select MONTH(GETDATE());
select MONTH('12/31/2019');

--YEAR function(Return the year number of a given date)--
select YEAR(GETDATE());
select YEAR('12/31/2019');

--DATENAME(Returns a string that represents a part of the given date)--
select DATENAME(DAY, GETDATE());
select DATENAME(DAY, '12/31/2019');
select DATENAME(WEEKDAY, GETDATE());
select DATENAME(MONTH, GETDATE());
select DATENAME(YEAR, GETDATE());
select DATENAME(HOUR, GETDATE());
select DATENAME(MINUTE, GETDATE());
select DATENAME(SECOND, GETDATE());
select DATENAME(NANOSECOND, GETDATE());
select DATENAME(MILLISECOND, GETDATE());
select DATENAME(QUARTER, GETDATE());
select DATENAME(TZ, SYSDATETIMEOFFSET());
select DATENAME(TZOFFSET, SYSDATETIMEOFFSET());

--##DatePart, DateAdd and DateDiff functions in SQL Server##--

--DATEPART function(Return an integer representing the specified date part)--
select DATEPART(WEEKDAY, GETDATE()); -- return weeday integer
select DATEnAME(WEEKDAY, GETDATE()); -- return weeday string

--DATEADD function(Return a datetime after adding a specific number to a date)--
select DATEADD(DAY, 5, GETDATE());
select DATEADD(DAY, 5, '2020-01-23 22:47:05.617');
select DATEADD(DAY, -5, '2020-01-23 22:47:05.617'); --substract--

--DATEDIFF function(Return the count of the specified datepar boundaries crossed between the specified start date and end date ---
select DATEDIFF(MONTH, '01/31/2019', '01/01/2020')
select DATEDIFF(DAY, '1960-06-30', '2020-06-30')
select DATEDIFF(YEAR, '1960-06-30', '2020-06-30')

--Day, Month and Year difference calculator customer function--
create function COMPUTEAGE(@dateofBirth datetime)
returns nvarchar(50)
as
begin
	Declare @tempdate datetime, 
			@year int, 
			@month int, 
			@day int 
	set @tempdate = @dateofBirth
	-- get the diffrence of years --
	select @year=DATEDIFF(YEAR, @tempdate, GETDATE()) -
				 CASE
					WHEN (MONTH(@dateofBirth) > MONTH(GETDATE()) OR (MONTH(@dateofBirth) = MONTH(GETDATE()) AND DAY(@dateofBirth) > DAY(GETDATE())))
					THEN 1 ELSE 0
				 END
	set @tempdate = DATEADD(YEAR, @year,  @tempdate)

	-- get the difference of months --
	select @month= DATEDIFF(MONTH, @tempdate, GETDATE()) -
				   CASE 
					   WHEN (DAY(@dateofBirth) > DAY(GETDATE()))
					   THEN 1 ELSE 0
					END
	set @tempdate = DATEADD(MONTH, @month, @tempdate)

	-- get the difference of days --
	select @day = DATEDIFF(DAY, @tempdate, GETDATE())
	--select @year as Years, @month as [Months], @day as [Day];--
	declare @result nvarchar(50)
	set @result = CAST(@year as nvarchar(50)) +' Years '+CAST(@month as nvarchar(10))+' Months '+ CAST(@day as nvarchar(10)) +' Days';
	return @result
end
--execute the user define function--
select DBO.COMPUTEAGE('12/30/2019')

--##Cast and Convert functions in SQL##---
--cast a datatype to another datatype in sql--
select CAST(GETDATE() as nvarchar);
select CAST(GETDATE() as DATE);
select CONVERT(nvarchar, GETDATE());
---cast using CONVERT method and style--
select CONVERT(nvarchar, GETDATE(), 111);
select CONVERT(int, '100');
select CONVERT(int, '1000000', 1);

--##Mathematical functions in sql server ##--
--ABS function(stands for absolute and returns)--
select ABS(-10.5);
select ABS(10.5);

--CEILING function(return the smallest integer value greater than or equal to the parameter.)--
select CEILING(15.2);
select CEILING(-15.2);

--FLOOR function(return the largest integer value less than or equal to the parameter.)--
select FLOOR(15.2);
select FLOOR(-15.2);

--POWER function(return the power value of a specific expression)--
select POWER(2, 3);

--SQUARE function(return the squre of a given number)--
select SQUARE(9);

--SQRT function(return the squre root of a given number)
select SQRT(81);

--RAND function(return random float number between 0 and 1)--
select RAND(1);
select FLOOR(RAND() * 100); --Return the random number between 1 and 100--

--ROUND function(round the given numeric expression based on the given lenght)--
select ROUND(850.556, 2); -- positive value round the right part of a decimal numeric value--
select ROUND(850.556, -2); -- negative value round the left part of a decimal numeric value--