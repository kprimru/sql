USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ClientTypeAllView]
AS
	/*
	SELECT a.ClientID, 
		MIN(
			CASE
				-- ������� ������ ����� ������� ��� �/� ������ ������ ����, ���, ���, ���� - ��� ��������� A
				WHEN (NT_NET > 1) OR (NT_NET = 1 AND SystemBaseName IN ('LAW', 'JURP', 'BVP', 'BUDP')) THEN 'A'
				-- �/� ������ ����� �������, ����� ����, ���, ���, ���� ��� ��������� ������ ����, ���, ���, ���� - ��� ��������� B
				WHEN (NT_NET = 1 AND SystemBaseName NOT IN ('LAW', 'JURP', 'BVP', 'BUDP')) 
					OR (SystemBaseName IN ('LAW', 'JURP', 'BVP', 'BUDP') AND NT_NET = 0) THEN 'B'
				-- ��� ��������� - ��� ��������� C
				ELSE 'C'
			END
		) AS CATEGORY
	FROM
		dbo.ClientTable a
		INNER JOIN dbo.ClientDistr b ON a.ClientID = b.ID_CLIENT
		INNER JOIN dbo.DistrStatus c ON c.DS_ID = b.ID_STATUS
		INNER JOIN dbo.SystemTable d ON d.SystemID = b.ID_SYSTEM
		INNER JOIN Din.NetType e ON e.NT_ID_MASTER = b.ID_NET
		--INNER JOIN dbo.DistrTypeTable e ON e.DistrTypeID = b.ID_NET
	WHERE DS_REG = 0 AND a.STATUS = 1 AND b.STATUS = 1
	GROUP BY a.ClientID
	*/
	SELECT a.ClientID, CATEGORY
	FROM
		dbo.ClientTable a
		CROSS APPLY
		(
			SELECT MIN(
					CASE
						-- ������� ������ ����� ������� ��� �/� ������ ������ ����, ���, ���, ���� - ��� ��������� A
						WHEN (NT_NET > 1) OR (NT_NET = 1 AND SystemBaseName IN ('LAW', 'JURP', 'BVP', 'BUDP')) THEN 'A'
						-- �/� ������ ����� �������, ����� ����, ���, ���, ���� ��� ��������� ������ ����, ���, ���, ���� - ��� ��������� B
						WHEN (NT_NET = 1 AND SystemBaseName NOT IN ('LAW', 'JURP', 'BVP', 'BUDP')) 
							OR (SystemBaseName IN ('LAW', 'JURP', 'BVP', 'BUDP') AND NT_NET = 0)
						-- ��� - ��� �� ������ ��� � 20.02.2019
						OR (NT_TECH = 13) THEN 'B'
						-- ��� ��������� - ��� ��������� C
						ELSE 'C'
					END
				) AS CATEGORY
			FROM dbo.ClientDistrView b WITH(NOEXPAND)
			INNER JOIN Din.NetType e ON e.NT_ID_MASTER = b.DistrTypeID
			WHERE a.ClientID = b.ID_CLIENT AND DS_REG = 0
		) AS b
	WHERE a.STATUS = 1