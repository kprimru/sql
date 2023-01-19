USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[RN_GET_STATUS_ID]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[RN_GET_STATUS_ID] () RETURNS Int AS BEGIN RETURN NULL END')
GO

-- ================================================
-- Автор:			коллектив авторов
-- Дата создания:	19.02.2009
-- Описание:		Выделяет ID статуса дистрибутива
--					из строки регузла
-- ================================================
CREATE FUNCTION [dbo].[RN_GET_STATUS_ID]
(
  @status VARCHAR(50)
)
RETURNS SMALLINT
AS
BEGIN
	DECLARE @result SMALLINT

	SET @result = NULL

	SELECT	@result = DS_ID
	FROM	dbo.DistrStatusTable
	WHERE	DS_REG = @status

	RETURN @result

END






GO
