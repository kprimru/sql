USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
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





