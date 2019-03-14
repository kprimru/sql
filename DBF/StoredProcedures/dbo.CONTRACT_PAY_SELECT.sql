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

CREATE PROCEDURE [dbo].[CONTRACT_PAY_SELECT]   
	@active BIT = NULL
AS

BEGIN
	SET NOCOUNT ON

	SELECT COP_ID, COP_NAME, COP_DAY, COP_MONTH
	FROM dbo.ContractPayTable 
	WHERE COP_ACTIVE = ISNULL(@active, COP_ACTIVE)
	ORDER BY COP_NAME

	SET NOCOUNT OFF
END



