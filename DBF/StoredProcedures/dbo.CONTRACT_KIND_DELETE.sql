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

CREATE PROCEDURE [dbo].[CONTRACT_KIND_DELETE]   
	@ID	SMALLINT
AS

BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.ContractKind
	WHERE CK_ID = @ID	

	SET NOCOUNT OFF
END

