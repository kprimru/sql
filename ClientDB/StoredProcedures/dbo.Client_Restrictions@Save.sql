USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[Client:Restrictions@Save]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[Client:Restrictions@Save]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[Client:Restrictions@Save]
    @Client_Id  Int,
    @Data       Xml
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE @Restrictions   Table
    (
        [Type_Id]   SmallInt,
        [Comment]   VarChar(Max),
        [Checked]   Bit
        PRIMARY KEY CLUSTERED([Type_Id])
    );

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		INSERT INTO @Restrictions
		SELECT
		    c.value('@Id[1]',       'SmallInt'),
		    c.value('@Comment[1]',  'VarChar(Max)'),
		    c.value('@Checked[1]',  'Bit')
		FROM @Data.nodes('/RESTRICTIONS/RESTRICTION') AS a(c);

		DELETE CR
		FROM [dbo].[Clients:Restrictions] AS CR
		WHERE [Client_Id] = @Client_Id
		    AND NOT EXISTS
		        (
		            SELECT *
		            FROM @Restrictions AS R
		            WHERE R.[Type_Id] = CR.[Type_Id]
		                AND R.[Checked] = 1
		        );

		UPDATE CR SET
		    [Comment] = R.[Comment]
		FROM [dbo].[Clients:Restrictions]   AS CR
		INNER JOIN @Restrictions            AS R ON CR.[Type_Id] = R.[Type_Id] AND R.[Checked] = 1
		WHERE CR.[Client_Id] = @Client_Id;

		INSERT INTO [dbo].[Clients:Restrictions]([Client_Id], [Type_Id], [Comment])
		SELECT @Client_Id, R.[Type_Id], R.[Comment]
		FROM @Restrictions AS R
		WHERE R.[Checked] = 1
		    AND NOT EXISTS
		        (
		            SELECT *
		            FROM [dbo].[Clients:Restrictions]   AS CR
		            WHERE CR.[Client_Id] = @Client_Id
		                AND CR.[Type_Id] = R.[Type_Id]
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
