USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Action]
(
        [ACTN_ID]        SmallInt        Identity(1,1)   NOT NULL,
        [ACTN_NAME]      VarChar(50)                     NOT NULL,
        [ACTN_ID_TYPE]   SmallInt                        NOT NULL,
        [ACTN_BEGIN]     SmallDateTime                       NULL,
        [ACTN_END]       SmallDateTime                       NULL,
        [ACTN_ACTIVE]    Bit                             NOT NULL,
        CONSTRAINT [PK_dbo.Action] PRIMARY KEY CLUSTERED ([ACTN_ID]),
        CONSTRAINT [FK_dbo.Action(ACTN_ID_TYPE)_dbo.ActionType(ACTT_ID)] FOREIGN KEY  ([ACTN_ID_TYPE]) REFERENCES [dbo].[ActionType] ([ACTT_ID])
);
GO
