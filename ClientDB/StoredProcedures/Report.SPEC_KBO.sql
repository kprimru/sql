USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[SPEC_KBO]
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
			ISNULL(ManagerName, SubhostName) AS '������������',
			CASE WHEN ManagerName IS NULL THEN NULL ELSE ServiceName END AS '��',
			a.DistrStr AS '�����������', NT_SHORT AS '����', ClientName AS '������', SST_SHORT AS '���',
			REVERSE(STUFF(REVERSE(
				(
					SELECT b.DistrStr + ','
					FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
					WHERE a.Complect = b.Complect
						AND b.DS_REG = 0
						AND b.SystemShortName <> a.SystemShortName
					ORDER BY SystemOrder FOR XML PATH('')
			)), 1, 1, '')) AS [�������������� �������]
		FROM dbo.RegNodeComplectClientView a
		WHERE a.SystemShortName NOT IN ('��', '���', '����', '�����')
			AND a.DS_REG = 0
			AND SST_SHORT IN ('����', '���')
			AND NOT EXISTS
				(
					SELECT *
					FROM Reg.RegNodeSearchView z WITH(NOEXPAND)
					WHERE z.Complect = a.Complect
						AND z.DS_REG = 0
						AND z.SystemBaseName = 'BORG'
				)
		ORDER BY ISNULL(ManagerName, ''), 1, 2, 4

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Report].[SPEC_KBO] TO rl_report;
GO