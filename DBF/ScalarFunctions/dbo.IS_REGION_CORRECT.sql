USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
-- =============================================
-- Автор:		  Денисов Алексей
-- Дата создания: 25.08.2008
-- Описание:	  Возвращает 0, если регион корректен 
--                (название присутствует в справочнике)
-- =============================================
CREATE FUNCTION [dbo].[IS_REGION_CORRECT]
(
	@region varchar(100)
)
RETURNS int
AS
BEGIN
	SET @region = RTRIM(LTRIM(@region))

    IF EXISTS(SELECT * FROM RegionTable WHERE RG_NAME = @region)
      RETURN 0
    ELSE
      RETURN 1

    RETURN 1

END

