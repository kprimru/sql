USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[WRONG_MAIN_SYSTEM]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT
			DistrStr AS '�����������', Comment AS '������', SST_SHORT AS '���', NT_SHORT AS '����',
			(
				SELECT TOP 1 b.DistrStr
				FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
				WHERE b.Complect = a.Complect
					AND b.DS_REG = 0
					AND b.DistrStr <> a.DistrStr
				ORDER BY b.SystemOrder
			) AS '�������� �������'
		FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
		WHERE DS_REG = 0
			AND SystemBaseName = 'RBAS020'
			AND SST_SHORT NOT IN ('���', '���', '���')
			AND NT_SHORT NOT IN ('���-� (1;2)', '���-� (0;1)')
			AND a.Complect IS NOT NULL
			AND NOT EXISTS
				(
					SELECT *
					FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
					WHERE a.Complect = b.Complect
						AND b.SystemBaseName IN ('BUHL', 'BUHUL',
												'SKBP', 'SKBO', 'SKBB',
												'SKJE', 'SKJP', 'SKJO', 'SKJB',
												'SKUE', 'SKUP', 'SKUO', 'SKUB',
												'SBOE', 'SBOP', 'SBOO', 'SBOB',
												'SPK-V', 'SPK-IV', 'SPK-III', 'SPK-II', 'SPK-I',
												'SKBEM', 'SKJEM', 'SKUEM', 'SBOEM')
				)

		UNION ALL

		SELECT DistrStr, Comment, SST_SHORT, NT_SHORT,
			(
				SELECT TOP 1 b.DistrStr
				FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
				WHERE b.Complect = a.Complect
					AND b.DS_REG = 0
					AND b.DistrStr <> a.DistrStr
				ORDER BY b.SystemOrder
			)
		FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
		WHERE DS_REG = 0
			AND SystemBaseName = 'EXP'
			AND SST_SHORT NOT IN ('���', '���', '���')
			AND a.Complect IS NOT NULL
			AND NOT EXISTS
				(
					SELECT *
					FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
					WHERE a.Complect = b.Complect
						AND b.SystemBaseName IN ('LAW', 'BVP', 'JURP', 'BUDP',
												'SKJP', 'SKUP', 'SBOP')
				)

		UNION ALL

		SELECT
			DistrStr AS '�����������', Comment AS '������', SST_SHORT AS '���', NT_SHORT AS '����',
			(
				SELECT TOP 1 b.DistrStr
				FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
				WHERE b.Complect = a.Complect
					AND b.DS_REG = 0
					AND b.DistrStr <> a.DistrStr
				ORDER BY b.SystemOrder
			) AS '�������� �������'
		FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
		WHERE DS_REG = 0
			AND SystemBaseName IN ('KDG', 'RBAS020')
			AND SST_SHORT NOT IN ('���', '���', '���')
			AND NT_SHORT NOT IN ('���-� (1;2)', '���-� (0;1)')
			AND a.Complect IS NOT NULL
			AND EXISTS
				(
					SELECT *
					FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
					WHERE a.Complect = b.Complect
						AND b.SystemBaseName IN (
														'SKBP', 'SKBO', 'SKBB',
												'SKJE', 'SKJP', 'SKJO', 'SKJB',
												'SKUE', 'SKUP', 'SKUO', 'SKUB',
												'SBOE', 'SBOP', 'SBOO', 'SBOB',
												'SPK-V', 'SPK-IV', 'SPK-III', 'SPK-II', 'SPK-I',
												'SKBEM', 'SKJEM', 'SKUEM', 'SBOEM')
				)

		UNION ALL

		SELECT
			DistrStr AS '�����������', Comment AS '������', SST_SHORT AS '���', NT_SHORT AS '����',
			(
				SELECT TOP 1 b.DistrStr
				FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
				WHERE b.Complect = a.Complect
					AND b.DS_REG = 0
					AND b.DistrStr <> a.DistrStr
				ORDER BY b.SystemOrder
			) AS '�������� �������'
		FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
		WHERE DS_REG = 0
			AND SystemBaseName IN ('RLAW020')
			AND NT_SHORT NOT IN ('���-� (1;2)', '���-� (0;1)')
			AND SST_SHORT NOT IN ('���', '���', '���')
			AND a.Complect IS NOT NULL
			AND EXISTS
				(
					SELECT *
					FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
					WHERE a.Complect = b.Complect
						AND b.SystemBaseName IN (
														'SKBP',
												'SKJE', 'SKJP',
												'SKUE', 'SKUP',
												'SBOE', 'SBOP',
												'SPK-V', 'SPK-IV', 'SPK-III', 'SPK-II', 'SPK-I')
				)


	------------------------��� ��� ��� ���, ���� ��� ����������------------------------------------------------------------

		UNION ALL

		SELECT
			DistrStr AS '�����������', Comment AS '������', SST_SHORT AS '���', NT_SHORT AS '����',
			(
				SELECT TOP 1 b.DistrStr
				FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
				WHERE b.Complect = a.Complect
					AND b.DS_REG = 0
					AND b.DistrStr <> a.DistrStr
				ORDER BY b.SystemOrder
			) AS '�������� �������'
		FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
		WHERE DS_REG = 0
			AND SystemBaseName IN ('PAS', 'FIN')
			AND NT_SHORT IN (	'���� 50', '1/�', '���� 255',
								'���� 150', '���� 100', '���� 5',
								'���� 250', '���� 200')
			AND SST_SHORT NOT IN ('���', '���', '���')
			AND a.Complect IS NOT NULL
			AND EXISTS
				(
					SELECT *
					FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
					WHERE a.Complect = b.Complect
						AND b.SystemBaseName = 'BUDP'
				)


		UNION ALL

		SELECT
			DistrStr AS '�����������', Comment AS '������', SST_SHORT AS '���', NT_SHORT AS '����',
			(
				SELECT TOP 1 b.DistrStr
				FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
				WHERE b.Complect = a.Complect
					AND b.DS_REG = 0
					AND b.DistrStr <> a.DistrStr
				ORDER BY b.SystemOrder
			) AS '�������� �������'
		FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
		WHERE DS_REG = 0
			AND (SystemBaseName = 'PAS')
			AND SST_SHORT NOT IN ('���', '���', '���')
			AND NT_SHORT IN (	'���� 50', '1/�', '���� 255',
								'���� 150', '���� 100', '���� 5',
								'���� 250', '���� 200')
			AND a.Complect IS NOT NULL
			AND EXISTS
				(
					SELECT *
					FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
					WHERE a.Complect = b.Complect
						AND b.SystemBaseName IN ('JURP' , 'BVP')
				)

		UNION ALL

		SELECT
			DistrStr AS '�����������', Comment AS '������', SST_SHORT AS '���', NT_SHORT AS '����',
			(
				SELECT TOP 1 b.DistrStr
				FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
				WHERE b.Complect = a.Complect
					AND b.DS_REG = 0
					AND b.DistrStr <> a.DistrStr
				ORDER BY b.SystemOrder
			) AS '�������� �������'
		FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
		WHERE DS_REG = 0
			AND (SystemBaseName = 'PAS')
			AND SST_SHORT NOT IN ('���', '���', '���')
			AND NT_SHORT IN ('���', '����', '���',
							'���-�', '���-� (1;2)',
							'���-� (0;1)', '���-� (1;0)')
			AND a.Complect IS NOT NULL
			AND EXISTS
				(
					SELECT *
					FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
					WHERE a.Complect = b.Complect
						AND b.SystemBaseName IN ('SBOP', 'SKUP', 'SKJP')
				)

		UNION ALL

		SELECT
			DistrStr AS '�����������', Comment AS '������', SST_SHORT AS '���', NT_SHORT AS '����',
			(
				SELECT TOP 1 b.DistrStr
				FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
				WHERE b.Complect = a.Complect
					AND b.DS_REG = 0
					AND b.DistrStr <> a.DistrStr
				ORDER BY b.SystemOrder
			) AS '�������� �������'
		FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
		WHERE DS_REG = 0
			AND (SystemBaseName = 'FIN')
			AND SST_SHORT NOT IN ('���', '���', '���')
			AND NT_SHORT IN ('���-� (1;2)', '���-� (0;1)', '���-� (1;0)')
			AND a.Complect IS NOT NULL
			AND EXISTS
				(
					SELECT *
					FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
					WHERE a.Complect = b.Complect
						AND b.SystemBaseName = 'SBOP'
				)

		UNION ALL

		SELECT
			DistrStr AS '�����������', Comment AS '������', SST_SHORT AS '���', NT_SHORT AS '����',
			(
				SELECT TOP 1 b.DistrStr
				FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
				WHERE b.Complect = a.Complect
					AND b.DS_REG = 0
					AND b.DistrStr <> a.DistrStr
				ORDER BY b.SystemOrder
			) AS '�������� �������'
		FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
		WHERE DS_REG = 0
			AND SystemBaseName IN ('RLAW020')
			AND NT_SHORT IN ('���-�', '���', '���', '����')
			AND SST_SHORT NOT IN ('���', '���', '���')
			AND a.Complect IS NOT NULL
			AND EXISTS
				(
					SELECT *
					FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
					WHERE a.Complect = b.Complect
						AND b.SystemBaseName IN ('SKBP','SKJE', 'SKJP',
												'SKUE', 'SKUP','SBOE',
												'SBOP')
				)

		/*
		UNION ALL

		SELECT
			DistrStr AS '�����������', Comment AS '������', SST_SHORT AS '���', NT_SHORT AS '����',
			(
				SELECT TOP 1 b.DistrStr
				FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
				WHERE b.Complect = a.Complect
					AND b.DS_REG = 0
					AND b.DistrStr <> a.DistrStr
				ORDER BY b.SystemOrder
			) AS '�������� �������'
		FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
		WHERE DS_REG = 0
			AND SystemBaseName IN ('RBAS020')
			AND SST_SHORT NOT IN ('���', '���', '���')
			AND a.Complect IS NOT NULL
			AND EXISTS
				(
					SELECT *
					FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
					WHERE a.Complect = b.Complect
						AND b.SystemBaseName IN (
														'SKBP', 'SKBO', 'SKBB',
												'SKJE', 'SKJP', 'SKJO', 'SKJB',
												'SKUE', 'SKUP', 'SKUO', 'SKUB',
												'SBOE', 'SBOP', 'SBOO', 'SBOB',
												'SPK-V', 'SPK-IV', 'SPK-III', 'SPK-II', 'SPK-I',
												'SKBEM', 'SKJEM', 'SKUEM', 'SBOEM')
				)
		*/

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[WRONG_MAIN_SYSTEM] TO rl_report;
GO