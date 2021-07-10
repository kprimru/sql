USE [DBF_NAH]
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
ALTER PROCEDURE [dbo].[CONSIGNMENT_SET_ORG]
	@consid INT,
	@orgid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ConsignmentTable
	SET CSG_ID_ORG = @orgid
	WHERE CSG_ID = @consid
END
GO
GRANT EXECUTE ON [dbo].[CONSIGNMENT_SET_ORG] TO rl_consignment_w;
GO