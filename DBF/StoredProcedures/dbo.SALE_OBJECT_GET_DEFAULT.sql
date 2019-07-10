USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[SALE_OBJECT_GET_DEFAULT]	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT * FROM dbo.SaleObjectTable WHERE SO_ID = 1
END
