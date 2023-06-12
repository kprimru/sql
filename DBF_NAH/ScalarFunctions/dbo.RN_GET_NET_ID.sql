﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[RN_GET_NET_ID]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[RN_GET_NET_ID] () RETURNS Int AS BEGIN RETURN NULL END')
GO

-- ================================================
-- Автор:			коллектив авторов
-- Дата создания:	19.02.2009
-- Описание:		Выделяет ID количества сетевый станций
--					из строки регузла
-- ================================================
CREATE FUNCTION [dbo].[RN_GET_NET_ID]
(
  @netcount VARCHAR(50)
)
RETURNS SMALLINT
AS
BEGIN
	DECLARE @result SMALLINT

	SET @result = NULL

	SELECT	@result = SNC_ID
	FROM	dbo.SystemNetCountTable
	WHERE	SNC_NET_COUNT = @netcount

	RETURN @result

END





GO
