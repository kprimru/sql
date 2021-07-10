USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 18.12.2008
Описание:	  Возвращает ID технологического
               признака с указанным названием.
*/

ALTER PROCEDURE [dbo].[TECHNOL_TYPE_CHECK_NAME]
	@technoltypename VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON

	SELECT TT_ID
	FROM dbo.TechnolTypeTable
	WHERE TT_NAME = @technoltypename

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[TECHNOL_TYPE_CHECK_NAME] TO rl_technol_type_w;
GO