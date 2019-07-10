USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:		  ������� �������
��������:	  
*/

CREATE PROCEDURE [dbo].[CONTRACT_PAY_GET] 
	@id SMALLINT = NULL  
AS

BEGIN
	SET NOCOUNT ON

	SELECT COP_ID, COP_NAME, COP_DAY, COP_MONTH, COP_ACTIVE
	FROM dbo.ContractPayTable 
	WHERE COP_ID = @id 	

	SET NOCOUNT OFF
END



