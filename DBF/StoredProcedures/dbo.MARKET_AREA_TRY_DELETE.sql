USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 05.11.2008
Описание:	  Возвращает 0, в случае если 
               сбытовую территорию можно удалить 
               (она не связани ни с однимподхостом), 
               -1 в противном случае
*/

CREATE PROCEDURE [dbo].[MARKET_AREA_TRY_DELETE] 
	@marketareaid INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	SELECT @res AS RES, @txt AS TXT

	-- добавлено 30.04.2009, В.Богдан
	IF EXISTS(SELECT * FROM dbo.SubhostCityTable WHERE SC_ID_MARKET_AREA = @marketareaid)
		BEGIN
			SET @res = 1
			SET @txt = @txt	+	'Невозможно удалить сбытовую территорию, так как она связана ' +
								'с одним или несколькими подхостами. '
		END
	--

	SET NOCOUNT OFF
END