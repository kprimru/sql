USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ClientCheckView]
AS	
	SELECT ClientID, ClientFullName, 'STATUS' AS TP, '�������� ������ ������� (������� "�����������", �� ��� �������������� �� �� ������)' AS ER
	FROM 
		dbo.ClientTable a
		INNER JOIN dbo.ServiceStatusTable ON ServiceStatusID = StatusID
	WHERE ServiceStatusReg = 0
		AND STATUS = 1
		AND NOT EXISTS
			(
				SELECT *
				FROM 
					dbo.ClientDistrView b WITH(NOEXPAND)
					INNER JOIN dbo.RegNodeTable d ON d.SystemName = b.SystemBaseName
												AND b.DISTR = d.DistrNumber
												AND b.COMP = d.CompNumber
				WHERE b.ID_CLIENT = a.ClientID AND DS_REG = 0
			)			

	UNION ALL
	
	SELECT ClientID, ClientFullName, 'STATUS', '�������� ������ ������� (�� ������� "�����������", �� ���� �������������� �� �� �������)'
	FROM 
		dbo.ClientTable a
		INNER JOIN dbo.ServiceStatusTable ON ServiceStatusID = StatusID
	WHERE ServiceStatusReg <> 0
		AND STATUS = 1
		AND EXISTS
			(
				SELECT *
				FROM 
					dbo.ClientDistrView b WITH(NOEXPAND)
					INNER JOIN dbo.RegNodeTable d ON d.SystemName = b.SystemBaseName
												AND b.DISTR = d.DistrNumber
												AND b.COMP = d.CompNumber
				WHERE b.ID_CLIENT = a.ClientID AND DS_REG = 0
			)
			
	UNION ALL
	
	SELECT ClientID, ClientFullName, 'INN', '�������� ���'
	FROM 
		dbo.ClientTable a
		INNER JOIN dbo.ServiceStatusTable b ON a.StatusID = b.ServiceStatusID
	WHERE ServiceStatusReg = 0 AND dbo.CheckINN(ClientINN) = 0 AND STATUS = 1

	UNION ALL

	SELECT ClientID, ClientFullName, 'SERVICE_TYPE', '�������� ��� ������������� (������ "' + 
									ServiceTypeShortName + '", ���������������� "' + 
									CASE UF_PATH
										WHEN 0 THEN '��'
										WHEN 1 THEN '�����'
										WHEN 2 THEN '��'
										ELSE '��'
									END + '")'
	FROM 
		dbo.ClientTable a
		INNER JOIN dbo.ServiceStatusTable b ON a.StatusID = b.ServiceStatusID
		INNER JOIN dbo.ServiceTypeTable c ON c.ServiceTypeID = a.ServiceTypeID
		INNER JOIN 
			(
				SELECT UD_ID_CLIENT, MAX(UF_PATH) AS UF_PATH
				FROM USR.ClientUSRPathView
				GROUP BY UD_ID_CLIENT
			) AS z ON UD_ID_CLIENT = ClientID
	WHERE ServiceStatusReg = 0 
		AND STATUS = 1
		AND 
			CASE 
				WHEN ServiceTypeShortName IN ('��', '����', '�����') THEN 0
				WHEN ServiceTypeShortName = '�����' THEN 1
				WHEN ServiceTypeShortName = '��' THEN 2
				ELSE -1
			END <> UF_PATH
		AND ServiceTypeShortName <> '������'

	UNION ALL

	SELECT a.ClientID, ClientFullName, 'ACTIVITY', '�� ������ ��� ������������'
	FROM 
		dbo.ClientTable a
		INNER JOIN dbo.ServiceStatusTable c ON ServiceStatusID = StatusID		
	WHERE ServiceStatusReg = 0 AND RTRIM(LTRIM(ISNULL(ClientActivity, ''))) = '' AND STATUS = 1

	UNION ALL

	SELECT a.ClientID, ClientFullName, 'PAPPER', '�������� ���������� �����. �������: ' + CONVERT(VARCHAR(20), ClientNewsPaper) + ', ������ ���� �� ������ ' + CONVERT(VARCHAR(20), ClientTypePapper)
	FROM 
		dbo.ClientTable a
		INNER JOIN dbo.ServiceStatusTable c ON ServiceStatusID = StatusID
		INNER JOIN dbo.ClientTypeAllView d ON d.ClientID = a.ClientID
		INNER JOIN dbo.ClientTypeTable b ON d.CATEGORY = b.ClientTypeName
	WHERE ServiceStatusReg = 0 AND ClientNewsPaper < ClientTypePapper AND STATUS = 1

	UNION ALL

	SELECT ClientID, ClientFullName, 'GRAPH', '��������� �������. ' + GR_ERROR
	FROM 
		dbo.ClientGraphView
	WHERE GR_ERROR IS NOT NULL
