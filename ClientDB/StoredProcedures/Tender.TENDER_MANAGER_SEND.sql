﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Tender].[TENDER_MANAGER_SEND]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Tender].[TENDER_MANAGER_SEND]  AS SELECT 1')
GO
ALTER PROCEDURE [Tender].[TENDER_MANAGER_SEND]
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

		DECLARE CLIENT CURSOR LOCAL FOR
			SELECT
				ID_CLIENT, CLIENT, ManagerLogin, MANAGER_DATE, MANAGER_NOTE

			FROM
				Tender.Tender
				INNER JOIN dbo.ManagerTable ON ManagerID = ID_MANAGER
			WHERE MANAGER = 1 AND STATUS = 1

		OPEN CLIENT

		DECLARE @CONDITION	NVARCHAR(MAX)
		DECLARE @MAN_DATE	SMALLDATETIME
		DECLARE @CL_NAME	NVARCHAR(256)
		DECLARE @CLIENT		INT
		DECLARE @MANAGER_LOGIN	NVARCHAR(128)
		DECLARE @MAN_NOTE NVARCHAR(MAX)

		FETCH NEXT FROM CLIENT INTO @CLIENT, @CL_NAME, @MANAGER_LOGIN, @MAN_DATE, @MAN_NOTE

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @CONDITION = 'Прошу до ' + CONVERT(NVARCHAR(32), @MAN_DATE, 108) + ' ' + CONVERT(NVARCHAR(32), @MAN_DATE, 104) +
			  ' для ' + @CL_NAME + ' подготовить и предоставить согласованный расчет стоимости информационный услуг на ' +
			  'сопровождаемый комплект систем КонсультантПлюс для подготовки и отправления коммерческих предложений ' + CHAR(10) + CHAR(10) + CHAR(13) + ISNULL(@MAN_NOTE, '')

			EXEC dbo.CLIENT_MESSAGE_SEND @CLIENT, 1, @MANAGER_LOGIN, @CONDITION, 0

			FETCH NEXT FROM CLIENT INTO @CLIENT, @CL_NAME, @MANAGER_LOGIN, @MAN_DATE, @MAN_NOTE
		END

		CLOSE CLIENT
		DEALLOCATE CLIENT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
