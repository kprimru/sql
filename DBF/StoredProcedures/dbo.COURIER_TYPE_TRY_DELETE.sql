﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[COURIER_TYPE_TRY_DELETE]
	@id SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @res INT
		DECLARE @txt VARCHAR(MAX)

		SET @res = 0
		SET @txt = ''

		-- изменено 30.04.2009, В.Богдан

		/*IF EXISTS(SELECT * FROM dbo.CLientTable WHERE CL_ID_COUR = @courierid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + 'Данный сервис-инженер указан у одного или нескольких ТО. ' +
							  'Удаление невозможно, пока выбранный сервис-инженер будет указан хотя ' +
							  'бы у одной ТО.'
		  END
		*/
		-- заменено на:
		IF EXISTS(SELECT * FROM dbo.CourierTable WHERE COUR_ID_TYPE = @id)
			BEGIN
				SET @res = 1
				SET @txt = @txt + 'Данный тип указан у одного или нескольких сервис-инженеров. ' +
								  'Удаление невозможно, пока выбранный тип будет указан хотя ' +
								  'бы у одного сервис-инженера.'
			END
		--

		SELECT @res AS RES, @txt AS TXT


		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
