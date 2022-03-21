import { microblog, createActor } from "../../declarations/microblog";
import { Principal } from "@dfinity/principal";

import React, { useState, useEffect, useRef } from 'react';
import {
    Layout, PageHeader, Menu, Card, Form, Input,
    Button, message, Divider, Spin, Empty
} from 'antd';
import BlogTable from "./blogtable";

const { Sider, Content } = Layout;

const MyFollow = (props) => {
    const [following, setFollowing] = useState(false);
    const [followerLoading, setFollowerLoading] = useState(false);
    const [followers, setFollowers] = useState([]);
    const [activeFollower, setActiveFollower] = useState(null);
    const actionRef = useRef();

    const getFollowers = async () => {
        setFollowerLoading(true);
        try {
            let followerList = await microblog.follows();
            console.log('follow list', followerList);
            setFollowers(followerList);
            if (followerList.length > 0) {
                setActiveFollower(followerList[0]);
            } else {
                setActiveFollower(null);
            }
        } catch (error) {
            message.error('获取关注列表失败!' + error);
        }
        setFollowerLoading(false);
    }


    const onFinish = async (values) => {
        console.log('Success:', values);
        setFollowing(true);
        try {
            await microblog.follow(Principal.fromText(values.canisterId));
            message.info('关注成功!');
        } catch (error) {
            message.error('关注失败!' + error);
        }
        setFollowing(false);
    };

    const onFinishFailed = (errorInfo) => {
        console.log('Failed:', errorInfo);
    };

    const onFollowChanged = (e) => {
        let blogger = followers.find(entry => Principal.from(entry.id).toText() === e.key);
        if (blogger) {
            setActiveFollower(blogger);
        } else {
            setActiveFollower(null);
        }
        
    }


    const renderFollowerList = () => {
        let renderMenuItems = () =>
            followers.map(entry => <Menu.Item key={Principal.from(entry.id).toText()}>
                {entry.name}
            </Menu.Item>);

        if (followers.length <= 0) {
            return <Empty />
        } else {
            return (<Menu onClick={onFollowChanged}
                defaultSelectedKeys={[Principal.from(followers[0].id).toText()]}>
                {renderMenuItems()}
            </Menu>);
        }
    }

    useEffect(() => {
        if (!following) {
            getFollowers();
        }
    }, [following]);
    useEffect(() => {
        if (activeFollower) {
            if (actionRef && actionRef.current) {
                actionRef.current.reloadAndRest();
            }
        }
    }, [activeFollower])

    return (
        <div>
            <Card title="请输入需要关注的canister id">
                <Form
                    name="newFollow"
                    initialValues={{}}
                    onFinish={onFinish}
                    onFinishFailed={onFinishFailed}
                    autoComplete="off"
                >
                    <Form.Item
                        label="canister id"
                        name="canisterId"
                        rules={[{ required: true, message: '请输入canister ids!' }]}
                    >
                        <Input />
                    </Form.Item>
                    <Form.Item wrapperCol={{ offset: 8, span: 16 }}>
                        <Button type="primary" htmlType="submit" loading={following}>
                            提交
                        </Button>
                    </Form.Item>
                </Form>
            </Card>
            <Divider />
            <PageHeader title="我关注的所有人" />
            <Layout>
                <Sider className="sider">
                    {followerLoading && <Spin />}
                    {!followerLoading && renderFollowerList()}
                </Sider>
                <Content>
                    {!!activeFollower && !followerLoading &&
                        <Card title={activeFollower.name + "的所有文章"}>
                            <BlogTable
                                actionRef={actionRef}
                                microblogMethod={createActor(activeFollower.id).posts}
                                showTimeFilter={false}
                                showAuthor={false}
                            />
                        </Card>
                    }
                </Content>
            </Layout>
        </div>
    )
}

export default MyFollow;