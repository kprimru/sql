﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[MonthOf]
(
    @DT     DateTime
)
RETURNS SMALLDATETIME
WITH SCHEMABINDING
AS
BEGIN
    RETURN (Convert(SmallDateTime,((Convert(VarChar(20),DATEPART(YEAR,@DT),0)+REPLICATE('0',(2)-LEN(CONVERT(VARCHAR(20),DATEPART(MONTH,@DT),0))))+CONVERT(VARCHAR(20),DATEPART(MONTH,@DT),0))+'01',(112)))
END
GO
