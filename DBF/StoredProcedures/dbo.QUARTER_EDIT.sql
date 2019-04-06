USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 15.10.2008
Описание:	  Изменить данные о периоде с 
               указанным кодом
*/

CREATE PROCEDURE [dbo].[QUARTER_EDIT] 
	@id		SMALLINT,
	@name	VARCHAR(50),
	@begin	SMALLDATETIME,
	@end	SMALLDATETIME,
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.Quarter
	SET QR_NAME = @name, 
		QR_BEGIN = @begin,
		QR_END = @end,
		QR_ACTIVE = @active
	WHERE QR_ID = @id

	SET NOCOUNT OFF
END
