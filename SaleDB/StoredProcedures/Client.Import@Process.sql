USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[Import@Process]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[Import@Process]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[Import@Process]
	@CompanyName			VarChar(256),
	@LegalForm				VarChar(32),
	@Inn					VarChar(256),
	@Address				VarChar(256),
	@Surname				VarChar(256),
	@Name					VarChar(256),
	@Patron					VarChar(256),
	@Activity				VarChar(256),
	@Phones					VarChar(256),
	@Email					VarChar(256),
	@Company_Id				UniqueIdentifier,
	@CheckedForCreate		Bit,
	@CheckedForUpdate		Bit
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

	DECLARE
		@Number			Int,
		@Phone			VarChar(128) = '',
		@Phone_S		VarChar(128),
		@Office_Id		UniqueIdentifier,
		@WorkMonth		UniqueIdentifier;

	DECLARE @PhonesList Table
	(
		[Phone]		VarChar(256),
		[Phone_S]	VarChar(256)
	);

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	BEGIN TRY
		BEGIN TRAN;

		SET @Phones = Replace(@Phones, '+7', '8');

		IF @CheckedForCreate = 1 BEGIN
			SET @CompanyName = Rtrim(Ltrim(Replace(@CompanyName, @LegalForm, ''))) + CASE WHEN @LegalForm = '' THEN '' ELSE ', ' + @LegalForm END;

			EXEC [Client].[COMPANY_NUMBER_GET]
				@NUM = @Number OUT;

			SELECT @WorkMonth = M.[ID]
			FROM [Common].[Month] AS M
			WHERE GetDate() BETWEEN M.[DATE] AND DateAdd(Month, 1, M.[DATE])

			INSERT INTO @PhonesList
			SELECT Ltrim(Rtrim(V.[value])), Replace(Replace(Replace(Replace(V.[value], '(', ''), ')', ''),  '-', ''),  ' ', '')
			FROM String_Split(@Phones, ',') AS V;

			EXEC [Client].[COMPANY_INSERT]
				@SHORT				= @CompanyName,
				@NAME				= @CompanyName,
				@NUMBER				= @Number,
				@PAY_CAT			= NULL,
				-- TODO: хардкод
				@WORK_STATE			= '1DC16C4C-E29F-E211-8EED-000C2933B2FD',
				@POTENTIAL			= NULL,
				@ACTIVITY			= NULL,
				@ACTIVITY_NOTE		= NULL,
				@SENDER				= NULL,
				@SENDER_NOTE		= NULL,
				@NEXT_MON			= @WorkMonth,
				@WORK_DATE			= NULL,
				@DELETE_COMMENT		= NULL,
				-- TODO: хардкод
				@AVAILABILITY		= '93C16C4C-E29F-E211-8EED-000C2933B2FD',
				@TAXING				= NULL,
				@WORK_STATUS		= NULL,
				@CHARACTER			= NULL,
				@REMOTE				= NULL,
				@EMAIL				= @Email,
				@BLACK_LIST			= NULL,
				@BLACK_NOTE			= NULL,
				@WORK_BEGIN			= NULL,
				@ID					= @Company_Id OUTPUT,
				@CARD				= NULL,
				@PAPER_CARD			= NULL,
				@TAXING_LIST		= NULL,
				@ACTIVITY_LIST		= NULL,
				@PROJECT			= NULL,
				@PROJECT_LIST		= NULL,
				@DEPO				= NULL,
				@DEPO_NUM			= NULL;
		END;

		IF @CheckedForUpdate = 1 OR @CheckedForCreate = 1 BEGIN
			IF NOT EXISTS(SELECT * FROM [Client].[Office] AS O WHERE O.[NAME] = @CompanyName AND O.[ID_COMPANY] = @Company_Id)
				EXEC [Client].[OFFICE_INSERT]
					@COMPANY			= @Company_Id,
					@SHORT				= @CompanyName,
					@NAME				= @CompanyName,
					@MAIN				= 1,
					@AREA				= NULL,
					@STREET				= NULL,
					@INDEX				= NULL,
					@HOME				= NULL,
					@ROOM				= NULL,
					@NOTE				= @Address,
					@ID					= @Office_Id OUTPUT;

			IF NOT EXISTS(SELECT * FROM [Client].[CompanyPersonal] AS P WHERE P.[ID_COMPANY] = @Company_Id AND P.[SURNAME] = @Surname AND P.[NAME] = @Name AND P.[PATRON] = @Patron)
				EXEC [Client].[COMPANY_PERSONAL_INSERT]
					@COMPANY	= @Company_Id,
					@OFFICE		= @Office_Id,
					@SURNAME	= @Surname,
					@NAME		= @Name,
					@PATRON		= @Patron,
					@POSITION	= NULL,
					@NOTE		= NULL,
					@ID			= NULL,
					@EMAIL		= NULL,
					@MAILING	= NULL;

			WHILE (1 = 1) BEGIN
				SELECT TOP (1)
					@Phone = L.[Phone],
					@Phone_S = L.[Phone_S]
				FROM @PhonesList AS L
				WHERE L.Phone > @Phone
				ORDER BY
					L.[Phone];

				IF @@RowCount < 1
					BREAK;

				IF NOT EXISTS (SELECT * FROM [Client].[CompanyPhone] AS P WHERE P.[ID_COMPANY] = @Company_Id AND P.[PHONE_S] = @Phone_S)
					EXEC [Client].[COMPANY_PHONE_INSERT]
						@COMPANY	= @Company_Id,
						@OFFICE		= @Office_Id,
						-- TODO: хардкод
						@TYPE		= 'F0A7874D-D1E4-E111-8DB5-000C2986905F',
						@PHONE		= @Phone,
						@PHONE_S	= @Phone_S,
						@NOTE		= '',
						@ID			= NULL;
			END;

			IF (NOT EXISTS (SELECT * FROM [Client].[CompanyInn] AS P WHERE P.[Company_Id] = @Company_Id AND P.[Inn] = @Inn) AND @Inn != '' AND @Inn IS NOT NULL)
				EXEC [Client].[COMPANY_INN_INSERT]
					@COMPANY		= @Company_Id,
					@INN			= @Inn,
					@NOTE			= '',
					@ID				= NULL;
		END;

		IF @@TranCount > 0
			COMMIT TRAN;
	END TRY
	BEGIN CATCH
		IF @@TranCount > 0
			ROLLBACK TRAN;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Client].[Import@Process] TO rl_company_import;
GO
