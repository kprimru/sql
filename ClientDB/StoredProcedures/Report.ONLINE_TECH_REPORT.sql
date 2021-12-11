USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[ONLINE_TECH_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[ONLINE_TECH_REPORT]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[ONLINE_TECH_REPORT]
	@PARAM NVARCHAR(MAX) = NULL
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

		DECLARE @HST_LAW INT
		SELECT @HST_LAW = HostID FROM dbo.Hosts WHERE HostReg = 'LAW'

		SELECT DistrStr AS [�����������], SST_SHORT AS [���], NT_SHORT AS [����], Comment AS [������], '�������������� ������� ��� ��������' AS [����������]
		FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
		WHERE HostID <> @HST_LAW
			AND NT_TECH > 1
			AND DS_REG = 0
			AND a.Complect IS NOT NULL
			AND NOT EXISTS
				(
					SELECT *
					FROM Reg.RegNodeSearchView z WITH(NOEXPAND)
					WHERE z.Complect = a.Complect
						AND z.DS_REG = 0
						AND z.HostID = @HST_LAW
				)

		UNION ALL

		SELECT DistrStr, SST_SHORT, NT_SHORT, Comment, '�� ��������� ���� ������'
		FROM
			Reg.RegNodeSearchView a WITH(NOEXPAND)
		WHERE NT_TECH > 1
			AND DS_REG = 0
			AND a.Complect IS NOT NULL
			AND EXISTS
				(
					SELECT *
					FROM Reg.RegNodeSearchView z WITH(NOEXPAND)
					WHERE z.Complect = a.Complect
						AND z.DS_REG = 0
						AND z.NT_TECH <> a.NT_TECH
				)
		ORDER BY [������]

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[ONLINE_TECH_REPORT] TO rl_report;
GO
