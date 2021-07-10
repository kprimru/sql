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

ALTER PROCEDURE [dbo].[CONSIGNMENT_SIGN]
	@consid INT,
	@consdate SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ConsignmentTable
	SET CSG_SIGN = @consdate
	WHERE CSG_ID = @consid
END

GO
GRANT EXECUTE ON [dbo].[CONSIGNMENT_SIGN] TO rl_consignment_w;
GO