IF Object_Id('dbo.ClientTypeRules', 'U') IS NULL BEGIN
    CREATE TABLE dbo.ClientTypeRules
    (
        [System_Id]     SmallInt    NOT NULL,
        [DistrType_Id]  SmallInt    NOT NULL,
        [ClientType_Id] SmallInt    NOT NULL,
        CONSTRAINT [PK_dbo.ClientTypeRules] PRIMARY KEY CLUSTERED ([System_Id], [DistrType_Id])
    );
    
   -- + �������� FK
END;
GO
-- ��������� ������� ������
INSERT INTO dbo.ClientTypeRules([System_Id], [DistrType_Id], [ClientType_Id])
SELECT S.[SystemID], D.[DistrTypeID], C.[ClientTypeID]
FROM dbo.SystemTable AS S
CROSS JOIN dbo.DistrTypeTable AS D
CROSS APPLY
(
    SELECT
        [Category] = CASE
                    -- ��� ����� ����� CASE �� ������ dbo.ClientTypeAllView � ������������ ��� ��� ������� S � D
) AS C 
INNER JOIN dbo.ClientTypeTable AS T ON T.[ClientTypeName] = C.[Category]
WHERE NOT EXISTS
    (
        SELECT *
        FROM dbo.ClientTypeRules AS R
        WHERE R.[System_Id] = S.[SystemID]
            AND R.[DistrType_Id] = D.[DistrTypeID]
    )
GO
CREATE VIEW dbo.ClientTypeRulesView AS
-- ��� ������ �� ����� ��������, ����� ������� dbo.ClientTypeRules
GO
--���������, ��� ��� ��������� ��������, ��� �� ������ ������ ��������. �������)

SELECT *
FROM dbo.ClientTypeRulesView

EXCEPT 

SELECT *
FROM dbo.ClientTypeAllView

SELECT *
FROM dbo.ClientTypeAllView

EXCEPT 

SELECT *
FROM dbo.ClientTypeRulesView
GO
--���� ��� �� - � ��������� dbo.CLIENT_TYPE_RECALCULATE ��������� �� ����� ����� ClientTypeRulesView

--���. ������.

--� ���! �� ������, ������ ��� ���� ��� ����� ������� �����������

--1. ������� ���������
--[dbo].[ClientTypeRules@Select]
--[dbo].[ClientTypeRule@Get]
--[dbo].[ClientTypeRule@Save] - ��� ���������� �������. � ������ - ���� ��������� ������� �������, ����� ��� ���������� ������ .�� ������� �� �����. ��� ��� ���� �� ������ ������� ��������
--[dbo].[ClientTypeRule@Recalculate Clients] - ����������� ��������� �� ���� ��������
--2. ������� �������� �� dbo.SystemTable � dbo.DistrTypeTable, ������� ����� ��������� ������� dbo.ClientTypeRules
--3. ������� ���������� � Delphi � �������� ��� �������������� �������.

--PROFIT!