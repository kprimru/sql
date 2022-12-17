﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Проценко Сергей
Описание:
*/

ALTER PROCEDURE [dbo].[SUBHOST_TYPE_TRY_DELETE]
	@subhostTypeId SMALLINT
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

		--IF EXISTS(SELECT * FROM dbo.PeriodRegTable WHERE REG_ID_HOST = @subhostTypeId)
		--	BEGIN
		--		-- изменено 4.05.2009
		--		SET @res = 1
		--		SET @txt = @txt + 'Невозможно удалить подхост, так как '
		--						+ 'имеются записи в истории рег.узла с данным подхостом.' + CHAR(13)
		--	END
		--IF EXISTS(SELECT * FROM dbo.PeriodRegNewTable WHERE RNN_ID_HOST = @subhostTypeId)
		--	BEGIN
		--		SET @res = 1
		--		SET @txt = @txt + 'Невозможно удалить подхост, так как '
		--						+ 'имеются записи о регистрации новых систем с данным подхостом.' + CHAR(13)
		--	END

		---- добавлено 29.04.2009, В.Богдан
		--IF EXISTS(SELECT * FROM dbo.ClientTable WHERE CL_ID_SUBHOST = @subhostTypeId)
		--	BEGIN
		--		SET @res = 1
		--		SET @txt = @txt + 'Невозможно удалить подхост, так как ему занесены клиенты. ' + CHAR(13)
		--	END
		--IF EXISTS(SELECT * FROM dbo.RegNodeFullTable WHERE RN_ID_SUBHOST = @subhostTypeId)
		--	BEGIN
		--		SET @res = 1
		--		SET @txt = @txt + 'Невозможно удалить подхост, так как он указан на рег.узле.'
		--	END
		--IF EXISTS(SELECT * FROM dbo.SubhostCityTable WHERE SC_ID_SUBHOST = @subhostid)
		--	BEGIN
		--		SET @res = 1
		--		SET @txt = @txt + 'Невозможно удалить подхост, на него ссылаются записи о городах подхостов.'
		--	END

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
GRANT EXECUTE ON [dbo].[SUBHOST_TYPE_TRY_DELETE] TO rl_subhost_type_d;
GO