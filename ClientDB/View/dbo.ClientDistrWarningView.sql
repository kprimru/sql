USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[ClientDistrWarningView]
AS
	-- ToDo - ���������� �� �����. ���� ��������������
	SELECT ClientID, REG_ERROR
	FROM
		(
			SELECT ID_CLIENT AS ClientID,
				CASE
					WHEN ISNULL(ISNULL(b.SubhostName, c.SubhostName), Maintenance.GlobalSubhostName()) <> Maintenance.GlobalSubhostName() THEN '����������� ���������� � ������� ��������'
					WHEN a.SystemReg = 0 THEN ''
					WHEN b.ID IS NULL THEN
						CASE
							WHEN c.ID IS NULL THEN '������� �� ������� � ��'
							ELSE '������� �������� (' + c.SystemShortName + ')'
						END
					WHEN a.DistrTypeID <> b.DistrTypeID THEN '�� ��������� ��� ����. � �� - ' + b.DistrTypeName
					WHEN a.DS_ID <> b.DS_ID THEN '�� ��������� ������ �������. � �� - ' + b.DS_NAME
					WHEN
						ISNULL((
							SELECT ID_CLIENT
							FROM
								dbo.ClientDistrView z WITH(NOEXPAND)
								INNER JOIN dbo.RegNodeMainDistrView y WITH(NOEXPAND) ON z.HostID = y.MainHostID AND z.DISTR = y.MainDistrNumber AND z.COMP = y.MainCompNumber
							WHERE y.SystemBaseName = a.SystemBaseName AND y.DistrNumber = a.DISTR AND y.CompNumber = a.COMP
						), a.ID_CLIENT) <> a.ID_CLIENT THEN '������� ���������������� � ��������� ������� ' + (
							SELECT ClientFullName + ' (' + y.Complect + ')'
							FROM
								dbo.ClientDistrView z WITH(NOEXPAND)
								INNER JOIN dbo.RegNodeMainDistrView y WITH(NOEXPAND) ON z.HostID = y.MainHostID AND z.DISTR = y.MainDistrNumber AND z.COMP = y.MainCompNumber
								INNER JOIN dbo.ClientTable x ON x.ClientID = z.ID_CLIENT
							WHERE y.SystemBaseName = a.SystemBaseName AND y.DistrNumber = a.DISTR AND y.CompNumber = a.COMP
						)
					ELSE ''
				END AS REG_ERROR
			FROM
				dbo.ClientDistrView a WITH(NOEXPAND)
				LEFT OUTER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON b.SystemID = a.SystemID
								AND b.DistrNumber = a.DISTR
								AND b.CompNumber = a.COMP
				LEFT OUTER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.HostID = a.HostID
								AND c.DistrNumber = a.DISTR
								AND c.CompNumber = a.COMP


			UNION ALL

			SELECT ID_CLIENT AS ClientID, '����������� ���������� � ��������� � ��������� �������'
			FROM
				dbo.ClientDistrView a WITH(NOEXPAND)
				INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON b.SystemID = a.SystemID
								AND b.DistrNumber = a.DISTR
								AND b.CompNumber = a.COMP
				INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.Complect = b.Complect
			WHERE  c.DS_REG = 0 AND c.DistrType NOT IN ('NEK')
				AND c.SubhostName = Maintenance.GlobalSubhostName()
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.ClientDistrView z WITH(NOEXPAND)
						WHERE /*z.ClientID = @CLIENTID
							AND */z.HostID = c.HostID
							AND z.DISTR = c.DistrNumber
							AND z.COMP = c.CompNumber
					)
		) AS o_O
	WHERE REG_ERROR <> ''
GO
