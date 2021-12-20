USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STT@Load?From Subhosts]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STT@Load?From Subhosts]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[STT@Load?From Subhosts]
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

        INSERT INTO [dbo].[ClientStat](FL_NAME, FL_SIZE, MD5, FL_DATA, FL_DATE, SYS_NUM, DISTR, COMP, OTHER)
        SELECT FL_NAME, FL_SIZE, MD5, FL_DATA, FL_DATE, SYS_NUM, DISTR, COMP, OTHER
        FROM [PC276-SQL\ART].[ClientDB].[dbo].[ClientStat] AS R
        WHERE NOT EXISTS
                (
                    SELECT *
                    FROM [dbo].[ClientStat] AS L
                    WHERE L.FL_NAME = R.FL_NAME
                        AND L.FL_SIZE = R.FL_SIZE
                        AND L.MD5 = R.MD5
                );

        INSERT INTO [dbo].[ClientStat](FL_NAME, FL_SIZE, MD5, FL_DATA, FL_DATE, SYS_NUM, DISTR, COMP, OTHER)
        SELECT FL_NAME, FL_SIZE, MD5, FL_DATA, FL_DATE, SYS_NUM, DISTR, COMP, OTHER
        FROM [PC276-SQL\USS].[ClientDB].[dbo].[ClientStat] AS R
        WHERE NOT EXISTS
                (
                    SELECT *
                    FROM [dbo].[ClientStat] AS L
                    WHERE L.FL_NAME = R.FL_NAME
                        AND L.FL_SIZE = R.FL_SIZE
                        AND L.MD5 = R.MD5
                );

        INSERT INTO [dbo].[ClientStat](FL_NAME, FL_SIZE, MD5, FL_DATA, FL_DATE, SYS_NUM, DISTR, COMP, OTHER)
        SELECT FL_NAME, FL_SIZE, MD5, FL_DATA, FL_DATE, SYS_NUM, DISTR, COMP, OTHER
        FROM [PC276-SQL\NKH].[ClientDB].[dbo].[ClientStat] AS R
        WHERE NOT EXISTS
                (
                    SELECT *
                    FROM [dbo].[ClientStat] AS L
                    WHERE L.FL_NAME = R.FL_NAME
                        AND L.FL_SIZE = R.FL_SIZE
                        AND L.MD5 = R.MD5
                );

        INSERT INTO [dbo].[ClientStat](FL_NAME, FL_SIZE, MD5, FL_DATA, FL_DATE, SYS_NUM, DISTR, COMP, OTHER)
        SELECT FL_NAME, FL_SIZE, MD5, FL_DATA, FL_DATE, SYS_NUM, DISTR, COMP, OTHER
        FROM [PC276-SQL\SLV].[ClientDB].[dbo].[ClientStat] AS R
        WHERE NOT EXISTS
                (
                    SELECT *
                    FROM [dbo].[ClientStat] AS L
                    WHERE L.FL_NAME = R.FL_NAME
                        AND L.FL_SIZE = R.FL_SIZE
                        AND L.MD5 = R.MD5
                );

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
