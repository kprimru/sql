USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[SYSTEM_UPDATE]
	@ID	INT,
	@SHORT	VARCHAR(20),
	@NAME	VARCHAR(200),
	@BASE	VARCHAR(50),
	@NUMBER	INT,
	@HOST	INT,
	@RIC	INT,
	@ORDER	INT,
	@VMI	INT,
	@FULL	VARCHAR(250),
	@ACTIVE	BIT,
	@DEMO	BIT,
	@COMPLECT	BIT,
	@REG	BIT,
	@IB_REQ	VARCHAR(MAX),
	@IB		VARCHAR(MAX),
	@WEIGHT	DECIMAL(8,4)
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS
		(
			SELECT Item
			FROM dbo.GET_TABLE_FROM_LIST(@IB, ',')

			INTERSECT

			SELECT Item
			FROM dbo.GET_TABLE_FROM_LIST(@IB_REQ, ',')
		)
	BEGIN
		DECLARE @BN	VARCHAR(MAX)	

		SELECT @BN = InfoBankShortName + ', '
		FROM 
			dbo.InfoBankTable
			INNER JOIN 
				(		
					SELECT Item
					FROM dbo.GET_TABLE_FROM_LIST(@IB, ',')

					INTERSECT

					SELECT Item
					FROM dbo.GET_TABLE_FROM_LIST(@IB_REQ, ',')
				) AS o_O ON InfoBankID = Item
		ORDER BY InfoBankShortName

		SET @BN = LEFT(@BN, LEN(@BN) - 1)		

		SET @BN = 'ИБ указаны как обязательные и как необязательные' + @BN

		RAISERROR (@BN, 16, 1)

		RETURN
	END

	UPDATE dbo.SystemTable
	SET	SystemShortName = @SHORT,
		SystemName = @NAME,
		SystemBaseName = @BASE,
		SystemNumber = @NUMBER,
		HostID = @HOST,
		SystemRic = @RIC,
		SystemOrder = @ORDER,
		SystemVMI = @VMI,
		SystemFullName = @FULL,
		SystemActive = @ACTIVE,
		SystemDemo	=	@DEMO,
		SystemComplect	=	@COMPLECT,
		SystemReg	=	@REG,
		SystemSalaryWeight = @WEIGHT,
		SystemLast = GETDATE()
	WHERE SystemID = @ID

	DELETE FROM dbo.SystemBankTable
	WHERE SystemID = @ID
		AND Required = 0
		AND InfoBankID NOT IN
			(
				SELECT Item
				FROM dbo.GET_TABLE_FROM_LIST(@IB, ',')
			)
			
	DELETE FROM dbo.SystemBankTable
	WHERE SystemID = @ID
		AND Required = 1
		AND InfoBankID NOT IN
			(
				SELECT Item
				FROM dbo.GET_TABLE_FROM_LIST(@IB_REQ, ',')
			)
	
	INSERT INTO dbo.SystemBankTable(SystemID, InfoBankID, Required)
		SELECT @ID, Item, 0
		FROM dbo.GET_TABLE_FROM_LIST(@IB, ',')
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.SystemBankTable
				WHERE SystemID = @ID
					AND InfoBankID = Item
			)	

	INSERT INTO dbo.SystemBankTable(SystemID, InfoBankID, Required)
		SELECT @ID, Item, 1
		FROM dbo.GET_TABLE_FROM_LIST(@IB_REQ, ',')
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.SystemBankTable
				WHERE SystemID = @ID
					AND InfoBankID = Item
			)	
END