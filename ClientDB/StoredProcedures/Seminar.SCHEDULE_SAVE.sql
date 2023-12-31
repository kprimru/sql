USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Seminar].[SCHEDULE_SAVE]
    @ID         UniqueIdentifier OUT,
    @SUBJECT    UniqueIdentifier,
    @DATE       SmallDateTime,
    @TIME       SmallDateTime,
    @LIMIT      SmallInt,
    @WEB        Bit,
    @PERSONAL   Bit,
    @QUESTIONS  Bit,
    @INVITE     SmallDateTime,
    @RESERVE    SmallDateTime,
    @PROFILE    SmallDateTime,
    @Type_Id    SmallInt,
    @Link       VarChar(Max),
    @Subhosts   Xml
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE
        @Status_Id_ACTIVE   Char(1);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

        SET @Status_Id_ACTIVE = 'A';

		IF @ID IS NULL
		BEGIN
			DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

			INSERT INTO Seminar.Schedule(ID_SUBJECT, DATE, TIME, LIMIT, WEB, PERSONAL, QUESTIONS, INVITE_DATE, RESERVE_DATE, PROFILE_DATE, [Type_Id], [Link], [Status_Id])
			OUTPUT inserted.ID INTO @TBL
			VALUES(@SUBJECT, @DATE, @TIME, @LIMIT, @WEB, @PERSONAL, @QUESTIONS, @INVITE, @RESERVE, @PROFILE, @Type_Id, @Link, @Status_Id_ACTIVE)

			SELECT @ID = ID
			FROM @TBL
		END
		ELSE
		BEGIN
			UPDATE Seminar.Schedule
			SET ID_SUBJECT	    =   @SUBJECT,
			    [Type_Id]       =   @Type_Id,
				DATE		    =   @DATE,
				TIME		    =   @TIME,
				LIMIT		    =   @LIMIT,
				WEB			    =   @WEB,
				PERSONAL	    =   @PERSONAL,
				QUESTIONS	    =   @QUESTIONS,
				INVITE_DATE	    =   @INVITE,
				RESERVE_DATE    =   @RESERVE,
				PROFILE_DATE    =   @PROFILE,
				[Link]          =   @Link,
				LAST		=	GETDATE()
			WHERE ID = @ID
		END

		DELETE
		FROM Seminar.ScheduleSubhosts
		WHERE Schedule_Id = @Id;

		INSERT INTO Seminar.ScheduleSubhosts(Schedule_Id, Subhost_Id, Limit)
		SELECT @Id, c.value('@Subhost_Id[1]', 'UniqueIdentifier'), c.value('@Limit[1]', 'SmallInt')
		FROM @Subhosts.nodes('/root/item') a(c)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Seminar].[SCHEDULE_SAVE] TO rl_seminar_admin;
GO
