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

CREATE PROCEDURE [dbo].[PRIMARY_PAY_DELETE]
	@prpid INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM dbo.PrimaryPayTable
	WHERE PRP_ID = @prpid
END
