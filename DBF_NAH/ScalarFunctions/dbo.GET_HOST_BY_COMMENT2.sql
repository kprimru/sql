﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GET_HOST_BY_COMMENT2]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[GET_HOST_BY_COMMENT2] () RETURNS Int AS BEGIN RETURN NULL END')
GO
-- =============================================
-- Автор:		  Денисов Алексей
-- Дата создания: 02.10.2008
-- Описание:	  Возвращает название подхоста
--                по комментарию из рег.узла
-- =============================================
CREATE FUNCTION [dbo].[GET_HOST_BY_COMMENT2]
(
    @Comment    VarChar(200),
    @Distr      Int,
    @System     VarChar(20),
	@SystemType VarChar(20)
)
RETURNS VarChar(10)
AS
BEGIN
    DECLARE
        @Host   VarChar(10),
        @Temp   VarChar(200);

    SET @Host = '';
    SET @Temp = '';
    SET @Comment = ISNULL(@Comment, '');

    -- для ДИУ
    IF @Distr = 20 OR @System = 'SKS' OR @SystemType = 'NEK' BEGIN
        IF CharIndex(')', Reverse(@Comment)) = 1 AND CharIndex('(', Reverse(@Comment)) != 0
            SET @Temp = Reverse(SubString(Reverse(@Comment), 2, CharIndex('(', Reverse(@Comment)) - 2))
        ELSE
            SET @Temp = ''
    END ELSE BEGIN
        IF CharIndex('(', @Comment) = 1 AND CharIndex(')', @Comment) != 0
            SET @Temp = SubString(@Comment, 2, CharIndex(')', @Comment) - 2);
        ELSE
            SET @Temp = '';
    END;

    IF Len(@Temp) > 3
        SET @Host = ''
    ELSE
        SET @Host = @Temp;

    RETURN @Host;
END
GO
