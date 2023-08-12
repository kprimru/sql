USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[IP].[CLIENT_COMPLECT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [IP].[CLIENT_COMPLECT_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [IP].[CLIENT_COMPLECT_SELECT]
	@CLIENT	INT,
	@ACTIVE BIT = 0
WITH EXECUTE AS OWNER
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
		--Инвертируем значение, так как активный статус обозначется как 0
		SET @ACTIVE = CASE WHEN @ACTIVE = 1 THEN 0 ELSE 1 END

		SELECT COMP_NAME, CSD_SYS, CSD_DISTR, CSD_COMP, SystemOrder, DS_REG, CSD_DATE
		FROM
			(
				SELECT
					dbo.DistrString(b.SystemShortName, a.DISTR, a.COMP) AS COMP_NAME,
					c.CSD_SYS, c.CSD_DISTR, c.CSD_COMP, b.SystemOrder, a.DS_REG,
					MAX(CSD_DATE) AS CSD_DATE
				FROM
					dbo.ClientDistrView a WITH(NOEXPAND)
					INNER JOIN dbo.SystemTable b ON a.HostID = b.HostID
					INNER JOIN IP.ClientStatView c ON b.SystemNumber = c.CSD_SYS
													AND a.DISTR = c.CSD_DISTR
													AND a.COMP = c.CSD_COMP
				WHERE a.ID_CLIENT = @CLIENT
				GROUP BY b.SystemShortName, c.CSD_SYS, c.CSD_DISTR, c.CSD_COMP, b.SystemOrder, a.DS_REG, a.DISTR, a.COMP
			) AS o_O
		WHERE	(@ACTIVE = 1 AND DS_REG = 0)
				OR (@ACTIVE = 0 AND DS_REG IN (0, 1, 2))
		ORDER BY DS_REG, CSD_DATE DESC, SystemOrder, CSD_DISTR, CSD_COMP

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [IP].[CLIENT_COMPLECT_SELECT] TO rl_client_ip;
GO
