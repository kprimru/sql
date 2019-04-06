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

CREATE PROCEDURE [dbo].[CONTRACT_KIND_SELECT]   
	@active BIT = NULL
AS

BEGIN
	SET NOCOUNT ON

	SELECT CK_ID, CK_NAME, CK_HEADER, CK_CENTER, CK_FOOTER
	FROM dbo.ContractKind
	WHERE CK_ACTIVE = ISNULL(@active, CK_ACTIVE)
	ORDER BY CK_NAME

	SET NOCOUNT OFF
END



