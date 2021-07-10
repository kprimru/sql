USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[COURIER_EDIT]
	@courierid SMALLINT,
	@couriername VARCHAR(100),
	@TYPE SMALLINT,
	@active BIT = 1,
	@city SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.CourierTable
	SET COUR_NAME = @couriername,
		COUR_ID_TYPE = @TYPE,
		COUR_ID_CITY = @city,
		COUR_ACTIVE = @active
	WHERE COUR_ID = @courierid

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[COURIER_EDIT] TO rl_courier_w;
GO