USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 23.09.2008
Описание:	  Возвращает 0, если тип сети
               с указанным кодом можно удалить
               (на него не ссылается ни одна
               запись в базе данных),
               -1 в противном случае
*/

ALTER PROCEDURE [dbo].[SYSTEM_NET_TRY_DELETE]
	@systemnetid SMALLINT
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

		-- добавлено 29.04.2009, В.Богдан
		IF EXISTS(SELECT * FROM dbo.DistrFinancingTable WHERE DF_ID_NET = @systemnetid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + 'Невозможно удалить тип сети, так как имеются финансовые установки с этим типом. '
			END

		IF EXISTS(SELECT * FROM dbo.SystemNetCountTable WHERE SNC_ID_SN = @systemnetid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + CHAR(13) + 'Невозможно удалить тип сети, так как с ним связано количество сетевых станций. '
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
GRANT EXECUTE ON [dbo].[SYSTEM_NET_TRY_DELETE] TO rl_system_net_d;
GO
