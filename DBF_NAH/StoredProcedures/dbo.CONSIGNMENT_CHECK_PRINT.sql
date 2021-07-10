USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:
���� ��������:  
��������:
*/

ALTER PROCEDURE [dbo].[CONSIGNMENT_CHECK_PRINT]
	@consid INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ConsignmentTable
	SET CSG_PRINT = 1
	WHERE CSG_ID = @consid
END

GO
GRANT EXECUTE ON [dbo].[CONSIGNMENT_CHECK_PRINT] TO rl_consignment_p;
GO