USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[ClientTypeAllView]
AS
	SELECT a.ClientID, CATEGORY
	FROM
		dbo.ClientTable a
		CROSS APPLY
		(
			SELECT MIN(
					CASE
						-- ������� ������ ����� ������� ��� �/� ������ ������ ����, ���, ���, ���� - ��� ��������� A

						WHEN (NT_NET > 1) OR (NT_NET = 1 AND SystemBaseName IN ('LAW', 'JURP', 'BVP', 'BUDP'))
						    -- 25.06.2021 ��� ��� ���
						    OR (NT_TECH = 13)
						        THEN 'A'
						-- �/� ������ ����� �������, ����� ����, ���, ���, ���� ��� ��������� ������ ����, ���, ���, ���� - ��� ��������� B
						-- + �����-��������� �� ������ ���� 20.03.2019
						WHEN (NT_NET = 1 AND SystemBaseName NOT IN ('LAW', 'JURP', 'BVP', 'BUDP', 'SBOE', 'SBOP', 'SKUP', 'SKUE', 'SKJP'))
							OR (SystemBaseName IN ('LAW', 'JURP', 'BVP', 'BUDP', 'SBOE', 'SBOP', 'SKUP', 'SKUE', 'SKJP') AND NT_NET = 0)
							-- ���-� (1;2) - ���� ��������� B 20.03.2019
							OR (NT_NET = 1 AND NT_TECH = 11 AND NT_ODON = 1 AND NT_ODOFF = 2)
								THEN 'B'
						-- ��� ��������� - ��� ��������� C
						ELSE 'C'
					END
				) AS CATEGORY
			FROM dbo.ClientDistrView b WITH(NOEXPAND)
			INNER JOIN Din.NetType e ON e.NT_ID_MASTER = b.DistrTypeID
			WHERE a.ClientID = b.ID_CLIENT AND DS_REG = 0
		) AS b
	WHERE a.STATUS = 1
GO
