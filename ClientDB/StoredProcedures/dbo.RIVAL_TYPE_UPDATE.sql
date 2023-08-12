﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[RIVAL_TYPE_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[RIVAL_TYPE_UPDATE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[RIVAL_TYPE_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(100)
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

		UPDATE dbo.RivalTypeTable
		SET RivalTypeName = @NAME
		WHERE RivalTypeID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[RIVAL_TYPE_UPDATE] TO rl_rival_u;
GO
